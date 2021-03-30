from datetime import date
from .database import connect_to_database
from .file_scanner import scan_for_docugen_files
from .verbose import verbose_print
from . import markdown_generator
from . import changelog

def find_last_mod_version(c, modVersion):
    version = c.execute(''' SELECT modVersion 
                            FROM FullChangeLog
                            WHERE modVersion <> ?
                            ORDER BY modVersion DESC
                            LIMIT 1''', [modVersion]).fetchone()

    if version == None:
        print("Failed to find previous mod version. Defaulting to 0")
        return 0

    return int(version[0])

def generate_change_logs(args):
    conn, c = connect_to_database()
    vanilla_version = args.vanilla_version
    mod_version = args.mod_version
    beta_version = args.beta_version
    prev_mod_version = find_last_mod_version(c, mod_version)

    verbose_print("Starting docugen for {}".format("CompMod"))
    verbose_print("Vanilla Version: {}".format(vanilla_version))
    verbose_print("Mod Version: {}".format(mod_version))
    if beta_version > 0:
        verbose_print("Beta Mod Version: {}".format(beta_version))
    verbose_print("Previous Mod Version: {}".format(prev_mod_version))

    # Populate database for new version
    scan_for_docugen_files(conn, c, mod_version, beta_version)

    # Generate full changelog
    create_changelog_against_vanilla(conn, c, vanilla_version, mod_version, beta_version)

    # Generate partial changelog
    create_changelog_stub(conn, c, mod_version, beta_version, prev_mod_version)

def create_changelog_against_vanilla(conn, c, vanilla_version, mod_version, beta_version):
    # Get changelog for version
    raw_changelog = []
    isBeta = beta_version > 0

    if isBeta:
        raw_changelog = c.execute('''SELECT key,value
                                     FROM BetaChangelog
                                     WHERE modVersion = ?
                                     AND betaVersion = ?
                                     ORDER BY key ASC''', [mod_version, beta_version]).fetchall()
    else:
        raw_changelog = c.execute('''SELECT key,value
                                    FROM FullChangelog
                                    WHERE modVersion = ?
                                    ORDER BY key ASC''', [mod_version]).fetchall()
    
    # Create tree from table
    tree = changelog.ChangeLogTree(raw_changelog)

    # Generate markdown text and write to changelog file
    with open("docs/changelog.md", "w+") as f:
        if isBeta:
            f.write("# Changes between {0} [revision {1} beta {2}](revisions/revision{1}b{2}.md) and Vanilla Build {3}\n".format("CompMod", mod_version, beta_version, vanilla_version))
        else:
            f.write("# Changes between {0} [revision {1}](revisions/revision{1}.md) and Vanilla Build {2}\n".format("CompMod", mod_version, vanilla_version))
        f.write("<br/>\n")
        f.write("\n")
        markdown_generator.generate(f, tree.root_node)

def create_changelog_stub(conn, c, mod_version, beta_version, prev_mod_version):
    # Get changelog for current version
    current_changelog = []
    isBeta = beta_version > 0

    if isBeta:
        current_changelog = c.execute('''SELECT key,value
                                         FROM BetaChangelog
                                         WHERE modVersion = ?
                                         AND betaVersion = ?
                                         ORDER BY key ASC''', [mod_version, beta_version]).fetchall()
    else:
        current_changelog = c.execute('''SELECT key,value
                                        FROM FullChangelog
                                        WHERE modVersion = ?
                                        ORDER BY key ASC''', [mod_version]).fetchall()
    
    prev_changelog = c.execute('''SELECT key,value
                                 FROM FullChangelog
                                 WHERE modVersion = ?
                                 ORDER BY key ASC''', [prev_mod_version]).fetchall()

    # Diff both changelogs
    diff = changelog.diff(current_changelog, prev_changelog)

    # Create tree from diff
    tree = changelog.ChangeLogTree(diff)

    # Write generated markdown to file
    filepath = "docs/revisions/revision"
    if isBeta:
        filepath = "{}{}b{}.md".format(filepath, mod_version, beta_version)
    else:
        filepath = "{}{}.md".format(filepath, mod_version)

    with open(filepath, "w+") as f:
        generate_nav_bar(f, mod_version, beta_version, prev_mod_version)
        
        if isBeta:
            f.write("# {} revision {} beta {} - ({})\n".format("CompMod", mod_version, beta_version, date.today().strftime("%d/%m/%Y")))
        else:
            f.write("# {} revision {} - ({})\n".format("CompMod", mod_version, date.today().strftime("%d/%m/%Y")))

        if len(diff) > 0:
            markdown_generator.generate_partial(f, tree.root_node)
        else:
            f.write("\n* No changes for this revision")
        f.write("\n<br/>\n\n")

        if prev_mod_version > 0:
            update_prev_nav_bar(mod_version, beta_version, prev_mod_version)
        
def generate_nav_bar(f, mod_version, beta_version, prev_mod_version):
    f.write('<div style="width:100%;background-color:#373737;color:#FFFFFF;text-align:center">\n')

    f.write('<div style="display:inline-block;float:left;padding-left:20%">\n')
    if prev_mod_version > 0:
        f.write('<a href="revision{}">\n'.format(prev_mod_version))
        f.write('[ <- Previous ]\n')
        f.write('</a>\n')
    else:
        f.write('[ <- Previous ]\n')
    f.write('</div>\n')

    f.write('<div style="display:inline-block;">\n')
    if beta_version > 0:
        f.write('Revision {} beta {}\n'.format(mod_version, beta_version))
    else:
        f.write('Revision {}\n'.format(mod_version))
    f.write('</div>\n')

    f.write('<div style="display:inline-block;float:right;padding-right:20%">\n')
    f.write('[ Next -> ]\n')
    f.write('</div>\n')

    f.write('</div>\n')

    f.write('\n<br />\n\n')

def update_prev_nav_bar(mod_version, beta_version, prev_mod_version):
    lines = None
    filepath = "docs/revisions/revision{}.md".format(prev_mod_version)
    with open(filepath, "r") as f:
        lines = f.readlines()
    
    i = 0
    for line in lines:
        i += 1
        if line == '<div style="display:inline-block;float:right;padding-right:20%">\n':
            break

    firstLines = lines[0:i]
    i += 1
    afterLines = lines[i:]

    with open(filepath, "w") as f:
        f.writelines(firstLines)
        if beta_version > 0:
            f.write('<a href="revision{}b{}">\n'.format(mod_version, beta_version))
        else:
            f.write('<a href="revision{}">\n'.format(mod_version))
        f.write('[ Next -> ]\n')
        f.write('</a>\n')
        f.writelines(afterLines)
