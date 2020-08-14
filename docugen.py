import sys
import sqlite3
import os

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

def die(errStr):
    print("Error: {}".format(errStr))
    exit(1)

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

def openConnection():
    return sqlite3.connect('docugen/data.db')

def usage():
    print("Docugen Usage")
    print("docugen vanillaVersion, modVersion, [oldModVersion]")
    exit(2)

def findLastModVersion(c):
    version = c.execute(''' SELECT modVersion 
                            FROM FullChangeLog
                            ORDER BY modVersion
                            LIMIT 1''').fetchone()

    if version == None:
        die("Failed to find last mod version. See usage")

    return version

def parseArgs(c, argc):
    if argc == 2:
        return (sys.argv) + [findLastModVersion(c)]
    elif argc == 3:
        return (sys.argv)
    else:
        usage()
    
def createTables(c):
    # First drop
    c.execute('''DROP TABLE IF EXISTS FullChangelog''')

    # Create tables
    c.execute('''CREATE TABLE FullChangelog(
                    modVersion varchar2(20) not null, 
                    key varchar2(100), 
                    value varchar2(100))''')

    print("Tables created successfully")

def addDocugenEntry(c, modVersion, data):
    key = data.pop(0).strip()
    for value in data:
        c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [modVersion, key, value.strip()])

def scanForDocugenFiles(conn, c, modVersion):
    # Delete any current entries for modVersion
    c.execute("DELETE FROM FullChangelog WHERE modVersion = ?", [modVersion])

    walkPath = os.path.join("src", "lua")
    dirs = next(os.walk(walkPath))[1]
    del dirs[dirs.index("entry")]
    modName = dirs[0]

    walkPath = os.path.join(walkPath, modName, "Modules")
    docugenFiles = []
    for root, dirs, files in os.walk(walkPath):
        if ".docugen" in files:
            docugenFiles.append(root)
 
    for path in docugenFiles:
        file = path + os.sep + ".docugen"
        with open(file, "r") as f:
            addDocugenEntry(c, modVersion, f.readlines())
        print("Processed module: {}".format(file))

    conn.commit()

def handleNonGenArgs(conn, c, argc):
    if argc == 0:
        return

    if sys.argv[0] == "--create" and argc == 1:
        createTables(c)
        exit(0)

    if sys.argv[0] == "--update-only" and argc == 2:
        scanForDocugenFiles(conn, c, sys.argv[1])
        exit(0)
    
    if sys.argv[0] == "--raw-dump" and argc == 1:
        print(c.execute("SELECT * FROM FullChangelog").fetchall())
        exit(0)

def printTree(node):
    key = node.key
    values = node.values
    print("{}".format(key))
    if len(values) > 0:
        for value in values:
            print("{}".format(value))
    
    for child in node.children:
        printTree(child)

def renderMarkdown(root, f, indentIndex=0, lineNo=0, imageUrl=None):
    key = root.key
    values = root.values

    if indentIndex == 0:
        if lineNo != 0:
            f.write("\n")
        f.write("# {}\n".format(key))
    elif indentIndex == 1:
        f.write("## {}\n".format(key))
    else:
        f.write(("  "*(indentIndex-2)) + "* {}\n".format(key))
    
    lineNo += 1
    indentIndex += 1

    if imageUrl != None:
        f.write('![alt text]({} "{}")\n'.format(imageUrl, key))

    for value in values:
        origIndentIndex = indentIndex
        i = 0
        for c in value:
            if c == ">":
                indentIndex += 1
                i += 1
            else:
                break
        value = value[i:]
        f.write(("  "*(indentIndex-2)) + "* {}\n".format(value))
        indentIndex = origIndentIndex

    lineNo = lineNo + len(values)

    for child in root.children:
        renderMarkdown(child, f, indentIndex, lineNo)

def generateMarkdown(f, rootNode):
    for initialNode in initialNodeOrder:
        imageUrl = imagesForNodes[initialNode]
        if rootNode.hasChild(initialNode):
            renderMarkdown(rootNode.getChild(initialNode), f, imageUrl=imageUrl)

def createFullChangelog(conn, c, vanillaVersion, modVersion):
    # Get changelog for version
    rawChangelog = c.execute("SELECT key,value FROM FullChangelog WHERE modVersion = ? ORDER BY key ASC", [modVersion]).fetchall()
    tree = ChangeLogTree(rawChangelog)
    with open(vsVanillaOutput, "w") as f:
        generateMarkdown(f, tree.rootNode)
    print("Changelog against vanilla generated")

def createPartialChangelog(conn, c, modVersion, oldModVersion):
    currentChangelog = c.execute("SELECT key,value FROM FullChangelog WHERE modVersion = ?", [modVersion]).fetchall()
    oldChangelog = c.execute("SELECT key,value FROM FullChangelog WHERE modVersion = ?", [oldModVersion]).fetchall()

def main():
    # We don't care about program name
    sys.argv.pop(0)
    argc = len(sys.argv)

    conn = openConnection()
    c = conn.cursor()
    handleNonGenArgs(conn, c, argc)

    vanillaVersion, modVersion, oldModVersion = parseArgs(c, argc)
    print("Starting docugen")
    print("Vanilla Version: {}".format(vanillaVersion))
    print("Mod Version: {}".format(modVersion))
    print("Old Mod Version: {}".format(oldModVersion))

    scanForDocugenFiles(conn, c, modVersion)
    createFullChangelog(conn, c, vanillaVersion, modVersion)
    createPartialChangelog(conn, c, modVersion, oldModVersion)

if __name__ == "__main__":
    main()
