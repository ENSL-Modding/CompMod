import sys
import os
import re

re_comments = re.compile("--.*\n")

def parse_file(filepath : str, tokens : dict = None):
    if not tokens:
        tokens = dict()

    data = None
    with open(filepath, "r") as f:
        data = f.read()

    data = re_comments.sub(" ", data)
    data = data.replace(" local ", " ")
    data = data.replace("\nlocal ", " ")

    eq_idx = data.rfind("=")
    end = data.find("\n", eq_idx)

    # Be careful here, make sure you don't lengthen the character count of the string
    data = data.replace("\n", " ")

    while eq_idx != -1:
        # Everything between the end of the line and the equal sign is our value
        value = data[eq_idx + 1:end].strip()

        # Now we find the name
        name_end = eq_idx - 1
        name_start = name_end

        # First skip over any spaces between the equals and the name
        if data[name_start] == " ":
            while name_start > 0 and data[name_start] == " ": name_start -= 1

        # Then find the next space, the substr inbetween the equals and this space is our name
        name_start = data.rfind(" ", 0, name_start)
        if name_start == -1:
            name_start = 0
        else:
            # Dont include the space in our name
            name_start += 1

        # Extract the name
        name = data[name_start:name_end].strip()

        if not name in tokens:
            tokens[name] = value

        # Set the end of the string to the start of our name minus the space
        end = name_start - 1

        # Find the next equals sign
        eq_idx = data.rfind("=", 0, eq_idx)

    return tokens


def check_for_unique_var_usage(var, compmod_src_path):
    for (dirpath, dirnames, filenames) in os.walk(compmod_src_path):
        for file in filenames:
            if file.endswith(".lua") and file != "Balance.lua":
                if check_for_var_in_file(var, os.path.join(dirpath, file)):
                    return True


    return False


def check_for_var_in_file(var : str, filepath : str ):
    data = None
    with open(filepath, "r") as f:
        data = f.read()

    data = re_comments.sub("", data)
    data = data.replace("\n", " ")

    return data.find(var) != -1


def main():
    (compmod_src_path, compmod_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath) = sys.argv[1:]

    compmod_tokens = parse_file(compmod_balance_filepath)
    vanilla_tokens = parse_file(vanilla_balance_health_filepath)
    vanilla_tokens = parse_file(vanilla_balance_misc_filepath, tokens = vanilla_tokens)
    vanilla_tokens = parse_file(vanilla_balance_filepath, tokens = vanilla_tokens)

    # Reverse our dicts key order so that it's in the order they appear in the Balance.lua file
    compmod_tokens = dict(reversed(list(compmod_tokens.items())))
    vanilla_tokens = dict(reversed(list(vanilla_tokens.items())))

    for var in compmod_tokens:
        c_value = compmod_tokens[var]
        if not var in vanilla_tokens:
            if not check_for_unique_var_usage(var, compmod_src_path):
                print("Warning: {} is not in vanilla and is not used in CompMod".format(var))
            continue

        v_value = vanilla_tokens[var]

        if c_value == v_value:
            print("Warning: {} has the same value in vanilla ({})".format(var, v_value))


if __name__ == "__main__":
    main()