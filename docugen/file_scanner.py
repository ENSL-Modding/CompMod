import os
from .verbose import verbose_print

def scan_for_docugen_files(conn, c, mod_version):
    # Delete any current entries for mod_version
    c.execute("DELETE FROM FullChangelog WHERE modVersion = ?", [mod_version])

    # Walk src/lua/ModName/Modules looking for .docugen files
    walk_path = os.path.join("src", "lua", "CompMod", "Modules")
    docugen_files = []
    verbose_print("Walking path: {}".format(walk_path))
    for root, dirs, files in os.walk(walk_path):
        if ".docugen" in files:
            verbose_print("Found .docugen file in {}".format(root))
            docugen_files.append(root)

    # Read all docugen files and add entries to database
    for path in docugen_files:
        file = path + os.sep + ".docugen"
        with open(file, "r") as f:
            data = f.readlines()
            key = data.pop(0).strip()
            for value in data:
                c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [mod_version, key, value.strip()])
        verbose_print("Processed module: {}".format(file))
    
    # Commit table changes
    conn.commit()
