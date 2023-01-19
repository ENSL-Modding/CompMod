import os
import re
from .verbose import verbose_print
from variable_parser import var_parser

def process_key(c, key, key_data, mod_version, beta_version):
    if len(key_data) > 0 and key:
        insert_to_database(c, mod_version, beta_version, key, key_data)
        verbose_print(" -> Processed key: {}".format(key))

def insert_to_database(c, mod_version, beta_version, key, key_data):
    for value in key_data:
        if beta_version > 0:
            c.execute("INSERT INTO BetaChangelog(modVersion, betaVersion, key, value) VALUES (?,?,?,?)", [mod_version, beta_version, key, value.strip()])
        else:
            c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [mod_version, key, value.strip()])

def scan_for_docugen_files(conn, c, mod_version, beta_version, local_src_path, vanilla_src_path, local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath):
    local_tokens, vanilla_tokens = var_parser.parse_local_and_vanilla(local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath)


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
                        process_key(c, key, key_data, mod_version, beta_version)

                        key = line[1:].strip()
                        key_data = []
                    else:
                        key_entry = process_key_entry(line.strip(), local_tokens, vanilla_tokens, local_src_path, vanilla_src_path)
                        key_data.append(key_entry)
                
                # Process the last key if there is one
                process_key(c, key, key_data, mod_version, beta_version)
    
    # Commit table changes
    conn.commit()


re_dynamic_vars = re.compile("\{\{([^ ]+(?:, ?[^ ]+)*)\}\}")
re_generated_statements = re.compile("^>*!(.*)$")
def process_key_entry(key_entry : str, local_tokens : dict, vanilla_tokens : dict, local_src_path : str, vanilla_src_path : str):
    dynamic_vars = re_dynamic_vars.findall(key_entry)
    generated_statements = re_generated_statements.findall(key_entry)

    # Replace dynamic vars with their values
    for s in dynamic_vars:
        value = None
        if s.find(",") != -1:
            var = s[0:s.index(",")]
            for m in re.finditer("([^ ]+)=([^,$]*)(?=,|$)", s):
                (name,value) = m.groups()
                
                if name == "format":
                    fmt = value

            if var.find(":") != -1:
                (filename, varname) = var.split(":")

                value = find_val_in_file(filename, varname, local_src_path)
            else:
                value = local_tokens[var]

            if fmt == "%":
                value = str(round(float(value) * 100, 2)) + "%"
        else:
            if s.find(":") != -1:
                (filename, varname) = s.split(":")

                value = find_val_in_file(filename, varname, local_src_path)
            else:
                value = local_tokens[s]

        key_entry = key_entry.replace("{{{{{}}}}}".format(s), value)
    
    for s in generated_statements:
        desc = None
        fmt = None
        suffix = ""
        additional_lookup = None

        var : str = s[0:s.index(",")]
        for m in re.finditer("([^ ]+)=([^,$]*)(?=,|$)", s):
            (name,value) = m.groups()
            
            if name == "description":
                desc = value
            elif name == "format":
                fmt = value
            elif name == "suffix":
                suffix = value
            elif name == "additional_lookup":
                additional_lookup = value.lower()

        to_val = None
        from_val = None

        if var.find(":") != -1:
            (filename, varname) = var.split(":")

            to_val = find_val_in_file(filename, varname, local_src_path)
            from_val = find_val_in_file(filename, varname, vanilla_src_path)
        else:
            to_val = local_tokens[var]
            from_val = vanilla_tokens[var]

        if additional_lookup == "vanilla":
            from_val = vanilla_tokens[from_val]
        elif additional_lookup == "compmod":
            to_val = local_tokens[to_val]

        # Perform any value modifications here before we figure out the verb
        if fmt == "-%":
            to_val = 1 - float(to_val)
            from_val = 1 - float(from_val)
            fmt = "%"

        verb = "Decreased" if to_val < from_val else "Increased"

        if fmt == '%':
            to_val = str(round(float(to_val) * 100, 2)) + "%"
            from_val = str(round(float(from_val) * 100, 2)) + "%"

        suffix_space = " " if len(suffix) > 0 else ""
        key_entry = "{0} {1} to {2}{3}{4} from {5} {4}".format(verb, desc, to_val, suffix_space, suffix, from_val)
    
    return key_entry


re_comments = re.compile("--.*$")
def find_val_in_file(filename : str, varname : str, src_path : str):
    re_custom_var = re.compile("{} *= *(.+)$".format(varname))
    for (dirpath, dirnames, filenames) in os.walk(src_path):
        if not filename in filenames:
            continue

        target_filepath = os.path.join(dirpath, filename)

        data = None
        with open(target_filepath, "r") as f:
            data = f.readlines()

        for line in data:
            line = re_comments.sub("", line)
            m = re_custom_var.match(line)
            if not m:
                continue

            value = m.groups()[0].strip()
            return value

    return None
