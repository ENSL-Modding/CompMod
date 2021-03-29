import os
from .verbose import verbose_print

def process_key(key, key_data, c, mod_version, beta_version):
    if len(key_data) > 0 and key:
        insert_to_database(c, mod_version, beta_version, key, key_data)
        verbose_print(" -> Processed key: {}".format(key))

def insert_to_database(c, mod_version, beta_version, key, key_data):
    for value in key_data:
        if beta_version > 0:
            c.execute("INSERT INTO BetaChangelog(modVersion, betaVersion, key, value) VALUES (?,?,?,?)", [mod_version, beta_version, key, value.strip()])
        else:
            c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [mod_version, key, value.strip()])

def scan_for_docugen_files(conn, c, mod_version, beta_version):
    # Delete any current entries for mod_version
    if beta_version > 0:
        c.execute("DELETE FROM BetaChangelog WHERE modVersion = ? AND betaVersion = ?", [mod_version, beta_version])
    else:
        c.execute("DELETE FROM FullChangelog WHERE modVersion = ?", [mod_version])

    # Walk docs-data looking for .docugen files
    walk_path = "docs-data"
    verbose_print("Walking path: {}".format(walk_path))
    for root, dirs, files in os.walk(walk_path):
        # Read all docugen files and add entries to database
        for file in files:
            full_filepath = root + os.sep + file
            with open(full_filepath, "r") as f:
                data = f.readlines()
                key_data = []
                key = None
                verbose_print("Processing docugen file: {}".format(file))
                for line in data:
                    # Ignore blank lines
                    if line == "\n":
                        continue

                    # This line is a key, store the value and populate its key_data array
                    if line.startswith("#"):
                        # Process key/values (if there are any)
                        process_key(key, key_data, c, mod_version, beta_version)

                        key = line[1:].strip()
                        key_data = []
                    else:
                        key_data.append(line.strip())
                
                # Process the last key if there is one
                process_key(key, key_data, c, mod_version, beta_version)
    
    # Commit table changes
    conn.commit()
