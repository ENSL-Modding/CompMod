import sys
import sqlite3
import os

def die(errStr):
    print("Error: {}".format(errStr))
    exit(1)

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
    # c.execute('''DROP TABLE IF EXISTS VersionInfo''')
    c.execute('''DROP TABLE IF EXISTS FullChangelog''')

    # Create tables
    # c.execute('''CREATE TABLE VersionInfo(
    #                 modVersion varchar2(20) primary key, 
    #                 releaseNotes text
    #                 )''')
    # c.execute('''CREATE TABLE FullChangelog(
    #                 modVersion varchar2(20) not null, 
    #                 key varchar2(100), 
    #                 value varchar2(100), 
    #                 CONSTRAINT fk_modVersion
    #                     FOREIGN KEY (modVersion)
    #                     REFERENCES VersionInfo(modVersion)
    #                 )''')
    c.execute('''CREATE TABLE FullChangelog(
                    modVersion varchar2(20) not null, 
                    key varchar2(100), 
                    value varchar2(100))''')

    print("Tables created successfully")

def addDocugenEntry(c, modVersion, data):
    key = data[0].strip()
    value = data[1].strip()

    c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [modVersion, key, value])

def scanForDocugenFiles(conn, c, modVersion):
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

def createFullChangelog(conn, c, vanillaVersion, modVersion):
    # Get changelog for version
    changelog = c.execute("SELECT key,value FROM FullChangelog WHERE modVersion = ?", [modVersion]).fetchall()


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
