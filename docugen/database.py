import sqlite3

def connect_to_database():
    conn = sqlite3.connect('docugen.db')
    c = conn.cursor()
    
    return conn, c

def initialize_tables(args):
    conn, c = connect_to_database()

    # First drop
    c.execute('''DROP TABLE IF EXISTS FullChangelog''')

    # Create tables
    c.execute('''CREATE TABLE FullChangelog(
                    modVersion varchar2(20) not null, 
                    key varchar2(100), 
                    value varchar2(100))''')
