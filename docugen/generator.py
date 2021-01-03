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
        verbose_print("Failed to find previous mod version. Defaulting to 0")
        return 0

    return int(version[0])

def generate_change_logs(args):
    conn, c = connect_to_database()
    vanilla_version = args.vanilla_version
    mod_version = args.mod_version
    prev_mod_version = find_last_mod_version(c, mod_version)

    verbose_print("Starting docugen for {}".format("CompMod"))
    verbose_print("Vanilla Version: {}".format(vanilla_version))
    verbose_print("Mod Version: {}".format(mod_version))
    verbose_print("Old Mod Version: {}".format(prev_mod_version))

    # Populate database for new version
    scan_for_docugen_files(conn, c, mod_version)

    # Generate full changelog
    create_changelog_against_vanilla(conn, c, vanilla_version, mod_version)

    # Generate partial changelog
    create_changelog_stub(conn, c, mod_version, prev_mod_version)

def create_changelog_against_vanilla(conn, c, vanilla_version, mod_version):
    # Get changelog for version
    raw_changelog = c.execute('''SELECT key,value
                                 FROM FullChangelog
                                 WHERE modVersion = ?
                                 ORDER BY key ASC''', [mod_version]).fetchall()
    
    # Create tree from table
    tree = changelog.ChangeLogTree(raw_changelog)

    # Generate markdown text and write to changelog file
    with open("docs/changelog.md", "w+") as f:
        f.write("# Changes between {0} [revision {1}](revisions/revision{1}.md) and Vanilla Build {2}\n".format("CompMod", mod_version, vanilla_version))
        f.write("<br/>\n")
        f.write("\n")
        markdown_generator.generate(f, tree.root_node)

def create_changelog_stub(conn, c, mod_version, prev_mod_version):
    # Get changelog for current version
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
    with open("docs/revisions/revision{}.md".format(mod_version), "w+") as f:
        f.write("# {} revision {} - ({})\n".format("CompMod", mod_version, date.today().strftime("%d/%m/%Y")))
        if len(diff) > 0:
            markdown_generator.generate_partial(f, tree.root_node)
        else:
            f.write("\n* No changes for this revision")
        f.write("\n<br/>\n\n")

        generate_nav_bar(f, mod_version, prev_mod_version)
        if prev_mod_version > 0:
            update_prev_nav_bar(mod_version, prev_mod_version)
        
def generate_nav_bar(f, mod_version, prev_mod_version):
    f.write('<div style="position:fixed;left:0;bottom:0;width:100%;background-color:#373737;color:#FFFFFF;text-align:center">\n')

    f.write('<div style="display:inline-block;float:left;padding-left:20%">\n')
    if prev_mod_version > 0:
        f.write('<a href="revision{}">\n'.format(prev_mod_version))
        f.write('[ <- Previous ]\n')
        f.write('</a>\n')
    else:
        f.write('[ <- Previous ]\n')
    f.write('</div>\n')

    f.write('<div style="display:inline-block;">\n')
    f.write('Revision {}\n'.format(mod_version))
    f.write('</div>\n')

    f.write('<div style="display:inline-block;float:right;padding-right:20%">\n')
    f.write('[ Next -> ]\n')
    f.write('</div>\n')

    f.write('</div>\n')

def update_prev_nav_bar(mod_version, prev_mod_version):
    lines = None
    with open("docs/revisions/revision{}.md".format(prev_mod_version), "r") as f:
        lines = f.readlines()
    
    del lines[-3:]
    with open("docs/revisions/revision{}.md".format(prev_mod_version), "w") as f:
        f.writelines(lines)
        f.write('<a href="revision{}">\n'.format(mod_version))
        f.write('[ Next -> ]\n')
        f.write('</a>\n')
        f.write('</div>\n')
        f.write('</div>\n')
