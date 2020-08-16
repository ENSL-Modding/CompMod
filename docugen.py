import sys
import sqlite3
import os
from datetime import date

initialNodeOrder = [
    "Alien", 
    "Marine", 
    "Spectator", 
    "Global", 
    "Fixes & Improvements"
]
imagesForNodes = {
    "Alien":                "https://wiki.naturalselection2.com/images/e/e5/All_Lifeforms_Banner.png",
    "Marine":               "https://wiki.naturalselection2.com/images/3/30/Marine_banner.png",
    "Spectator":            "https://wiki.naturalselection2.com/images/0/0a/Marine_Structures_Banner.png",
    "Global":               "https://wiki.naturalselection2.com/images/3/35/Resource_Model_Banner.png",
    "Fixes & Improvements": "https://wiki.naturalselection2.com/images/1/17/Tutorial_Banner.png"
}

vsVanillaOutput = "docs/changes.md"
compModChangelogOutput = "docs/full_changelog.md"

# NoReturn
def die(errStr):
    print("Error: {}".format(errStr))
    exit(1)

# NoReturn
def usage():
    print("Docugen Usage")
    print("docugen vanillaVersion, modVersion, [oldModVersion]")
    print("")
    print("--create                   Create tables and exit")
    print("--update-only modVersion   Only update table, don't write changelogs")
    print("--raw-dump                 Dump all data from table")
    exit(2)

class ChangeLogNode:
    def __init__(self, key, parent=None):
        self.key = key
        self.parent = parent
        self.children = []
        self.values = []

    def getChild(self, key):
        for child in self.children:
            if child.key == key:
                return child
        
        return None

    def hasChild(self, key):
        return self.getChild(key) != None

    def addChild(self, key, value):
        child = ChangeLogNode(key, value)
        self.children.append(child)

        return child
    
    def addValue(self, value):
        self.values.append(value)

class ChangeLogTree:
    def __init__(self, rawChangelog):
        self.rootNode = ChangeLogNode("root")
        for key,value in rawChangelog:
            self.injestKey(self.rootNode, key, value)

    def injestKey(self, root, key, value):
        if "." in key:
            subkeys = key.split(".")
            rootSubkey = subkeys[0]
            node = None
            if root.hasChild(rootSubkey):
                node = root.getChild(rootSubkey)
            else:
                node = root.addChild(rootSubkey, root)

            if not node:
                die("Failed to injest key")

            self.injestKey(node, ".".join(subkeys[1:]), value)
        else:
            if root.hasChild(key):
                node = root.getChild(key)
            else:
                node = root.addChild(key, root)
            node.addValue(value)

def main():
    # Pop program name
    sys.argv.pop(0)

    argc = len(sys.argv)
    if argc == 0:
        usage()

    # Connect to db
    conn = sqlite3.connect('docugen/data.db')
    c = conn.cursor()

    # Handle special cases
    if sys.argv[0] == "--create" and argc == 1:
        createTables(c)
        return
    
    if sys.argv[0] == "--update-only" and argc == 2:
        scanForDocugenFiles(conn, c, sys.argv[1])
        return

    if sys.argv[0] == "--raw-dump":
        if argc == 1:
            print(c.execute("SELECT * FROM FullChangelog").fetchall())
        elif argc == 2:
            print(c.execute("SELECT * FROM FullChangelog WHERE modVersion = ?", sys.argv[1]).fetchall())
        return

    # Populate argument vars
    if argc == 2:
        vanillaVersion, modVersion = (sys.argv)
        oldModVersion = findLastModVersion(c, modVersion)
    elif argc == 3:
        vanillaVersion, modVersion, oldModVersion = (sys.argv)
    else:
        usage()

    # Abort if current version matches previous version
    if modVersion == oldModVersion:
        die("Current mod version matches previous mod version")

    print("Starting docugen")
    print("Vanilla Version: {}".format(vanillaVersion))
    print("Mod Version: {}".format(modVersion))
    print("Old Mod Version: {}".format(oldModVersion))

    # Populate database for new version
    scanForDocugenFiles(conn, c, modVersion)

    # Generate full changelog
    createFullChangelog(conn, c, vanillaVersion, modVersion)

    # Generate partial changelog
    createPartialChangelog(conn, c, modVersion, oldModVersion)
    
def createTables(c):
    # First drop
    c.execute('''DROP TABLE IF EXISTS FullChangelog''')

    # Create tables
    c.execute('''CREATE TABLE FullChangelog(
                    modVersion varchar2(20) not null, 
                    key varchar2(100), 
                    value varchar2(100))''')

    print("Tables created successfully")

def findLastModVersion(c, modVersion):
    version = c.execute(''' SELECT modVersion 
                            FROM FullChangeLog
                            WHERE modVersion <> ?
                            ORDER BY modVersion DESC
                            LIMIT 1''', [modVersion]).fetchone()[0]

    if version == None:
        die("Failed to find last mod version. See usage")

    return version

def scanForDocugenFiles(conn, c, modVersion):
    # Delete any current entries for modVersion
    c.execute("DELETE FROM FullChangelog WHERE modVersion = ?", [modVersion])

    # Get the modname
    walkPath = os.path.join("src", "lua")
    dirs = next(os.walk(walkPath))[1]
    del dirs[dirs.index("entry")]
    modName = dirs[0]

    # Walk src/lua/{modName}/Modules looking for .docugen files
    walkPath = os.path.join(walkPath, modName, "Modules")
    docugenFiles = []
    for root, dirs, files in os.walk(walkPath):
        if ".docugen" in files:
            docugenFiles.append(root)
 
    # Read all docugen files and add entries to database
    for path in docugenFiles:
        file = path + os.sep + ".docugen"
        with open(file, "r") as f:
            addDocugenEntry(c, modVersion, f.readlines())
        # print("Processed module: {}".format(file))

    # Commit table changes
    conn.commit()

def addDocugenEntry(c, modVersion, data):
    key = data.pop(0).strip()
    for value in data:
        c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [modVersion, key, value.strip()])

def createFullChangelog(conn, c, vanillaVersion, modVersion):
    # Get changelog for version
    rawChangelog = c.execute('''SELECT key,value 
                                FROM FullChangelog 
                                WHERE modVersion = ? 
                                ORDER BY key ASC''', [modVersion]).fetchall()

    # Create tree from table
    tree = ChangeLogTree(rawChangelog)

    # Generate markdown text and write to changelog file
    with open(vsVanillaOutput, "w") as f:
        f.write("# Changes between CompMod {} and Vanilla {}\n".format(modVersion, vanillaVersion))
        f.write("<br/>\n")
        f.write("\n")
        generateMarkdown(f, tree.rootNode)

    print("Changelog against vanilla generated")

def createPartialChangelog(conn, c, modVersion, oldModVersion):
    # Create entry stub
    stub = "# CompMod - {} ({})\n".format(modVersion, date.today().strftime("%d/%m/%Y"))

    # Get changelog for current version
    currentChangelog = c.execute('''SELECT key,value 
                                    FROM FullChangelog 
                                    WHERE modVersion = ? 
                                    ORDER BY key ASC''', [modVersion]).fetchall()

    # Get changelog for previous version
    oldChangelog = c.execute('''SELECT key,value 
                                FROM FullChangelog 
                                WHERE modVersion = ? 
                                ORDER BY key ASC''', [oldModVersion]).fetchall()

    # Diff both changelogs
    diff = changelogDiff(currentChangelog, oldChangelog)

    # Create tree from diff
    tree = ChangeLogTree(diff)

    # Prepend generated markdown to file
    with open(compModChangelogOutput, "r+") as f:
        content = f.read()
        f.seek(0,0)
        f.write(stub)
        if len(diff) > 0:
            generatePartialMarkdown(f, tree.rootNode)
        f.write("\n<br/>\n\n")
        f.write(content)

    print("CompMod changelog generated")

def generateMarkdown(f, rootNode):
    for initialNode in initialNodeOrder:
        imageUrl = imagesForNodes[initialNode]
        if rootNode.hasChild(initialNode):
            renderMarkdown(rootNode.getChild(initialNode), f, imageUrl=imageUrl)

def generatePartialMarkdown(f, rootNode):
    for initialNode in initialNodeOrder:
        if rootNode.hasChild(initialNode):
            renderMarkdown(rootNode.getChild(initialNode), f, additionalHeaderLevel=1)

def renderMarkdown(root, f, indentIndex=0, lineNo=0, imageUrl=None, additionalHeaderLevel=0):
    key = root.key
    values = root.values

    # First we write the key, heading/bullet point level depends on indentIndex. We can control the initial header level by changing additionalHeaderLevel
    if indentIndex == 0:
        if lineNo != 0:
            f.write("\n")

        f.write("#"*additionalHeaderLevel + "# {}\n".format(key))
    elif indentIndex == 1:
        f.write("#"*additionalHeaderLevel + "## {}\n".format(key))
    else:
        f.write(("  "*(indentIndex-2)) + "* {}\n".format(key))
    
    # Increment lineNo and indentIndex
    lineNo += 1
    indentIndex += 1

    # Write image tag out if we have one
    if imageUrl != None:
        f.write('![alt text]({} "{}")\n'.format(imageUrl, key))

    # Write all values 
    for value in values:
        origIndentIndex = indentIndex
        i = 0

        # Values can be prefixed with ">" to indent. Increment indentIndex for each occurence.
        for c in value:
            if c == ">":
                indentIndex += 1
                i += 1
            else:
                break
        
        # Remove any leading ">" chars
        value = value[i:]
        
        # Write value 
        f.write(("  "*(indentIndex-2)) + "* {}\n".format(value))

        # Restore original indentIndex
        indentIndex = origIndentIndex

    # Increment lineNo by the number of values written
    lineNo = lineNo + len(values)

    # Call renderMarkdown recursively for every child node
    for child in root.children:
        renderMarkdown(child, f, indentIndex, lineNo, additionalHeaderLevel=additionalHeaderLevel)

def changelogDiff(curr, old):
    diff = []

    # Iterate through all key/value pairs in currentChangelog
    for key,value in curr:
        foundKey = False
        foundValue = False

        # With a single key/value pair in curr, look for a matching one in the oldChangelog
        for key2,value2 in old:
            if key == key2:
                foundKey = True
                if value2 == value:
                    foundValue = True
            elif foundKey:
                break
    
        # If we didn't find a match for the key in old it means the key/value was added
        if not foundKey:
            # print("Diff: Adding {} because the key wasn't found".format(key))
            diff.append((key, value))
            continue

        # If we did find a key but didn't find a value, it means that a key/value pair was modified.
        if not foundValue:
            # print("Diff: Adding {} because values didn't match".format(key))
            diff.append((key, value))
            continue
    
    return diff

if __name__ == "__main__":
    main()
