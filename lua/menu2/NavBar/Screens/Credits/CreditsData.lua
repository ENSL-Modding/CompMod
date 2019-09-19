-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/Credits/GUIMenuCredits.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    All of the game's credits data, segmented by groups and when they were active
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--?? Specify transition type?
--?? Specify onScreenTime?
--?? Page / Section Names?
gGameCreditsData = 
{
    {
        title = "Current Development Team",
        autoTime = 8,
        style = "bold",
        members = 
        {
            "Dillon \"WasabiOne\" Savage (Operations, Team Lead)",
            "Chris \"Ironhorse\" Gates (Quality Assurance Lead)",
            "Brock \"McGlaspie\" Gillespie (Lead Programmer)",
            "Trevor \"BeigeAlert\" Harris (Programmer)",
            "Sebastian \"Ghoul\" Schuck (Programmer)",
            "Brian \"Samoose\" Arneson (Programmer)",
            "Thomas \"fsfod\" Fransham (Programmer)",
            "Joey \"simba\" Hutchins (Programmer)",
            "Amanda \"Rantology\" Diaz (UI and Concept Artist)",
        }
    },

    {
        title = "Current Community Developers",
        autoTime = 7,
        style = "bold",
        members =
        {
            "Eric \"sweets\" Swietlicki (Audio Engineering)",
            "Kevin \"Steelcap\" Kicklighter (Programmer)",
            "Sven \"Handschuh\" Fischer (Programmer)",
            "Marco \"RuneStorm\" Axer (VFX)",
            "PaulWolfe (Environment Art)",
            "Vlaad (Modeling and Animation)",
            "Kash (Level Design and Map Fixes)"
        }
    },

    {
        title = "Original San Francisco Team", 
        autoTime = 8,
        style = "bold",
        members = 
        {
            "Charlie Cleveland (CEO, Co-Founder, and Design Director)",
            "Max McGuire (Co-Founder and Technical Director)",
            "Cory Strader (Art Director)",
            "Brian Cronin (Lead Programmer)",
            "Dushan Leska (Engine Programmer)",
            "Steve \"Rock\" An (Programmer)",
            "Brian Cummings (Technical Artist)",
            "Lilly Baker (Office Manager)",
            "Hugh Jeremy",
        }
    },

    {
        title = "Original Off-site Team", 
        autoTime = 15,
        members = 
        {
            "Steve Bodnar (Animation)",
            "Colin Knueppel (Animation)",
            "I Gede Mahendra (Animation, R.I.P.)",
            "Brandt Wojak (Animation)",
            "Levi Gilbert (Animation Intern)",
            "Dan Romans (Animation Intern)",
            "Alex Perry (Environment Art)",
            "Bill Smith (Environment Art)",
            "Liam Tart (Environment Art)",
            "Amanda \"Rantology\" Diaz (UI Art)",
            "Andreas Urwalek (Programming)",
            "Oli Hobbs (Level Design)",
            "Andrew Jones (Level Design)",
            "Marc Newton (Level Design)",
            "Jake Smith (Level Design)",
            "Michael Schouten (Level Design)",
            "David John (Music)",
            "Simon Chylinski (Sound Design, Music)",
            "Thomas \"acidrain\" Loupe (Assistant Sound Design)",
            "Sylvain Hel (VFX)",
            "Lukas \"AceDude\" Nowaczek (Web Programming, Localization)",
        }
    },

    {
        title = "Fox3D Studios",
        autoTime = 10,
        groups = 
        {
            {
                subtitle = "Artwork",
                forceNewline = true,
                members =
                {
                    "Den Fox [Denis Lis]  (CEO and Creative Director)",
                    "Maxim Miheyenko  (Manager of Studios operations)",
                    "Sergey Solovyev  (Lead 3D Artist)"
                }
            },
            {
                subtitle = "Concept Artists",
                colWidth = 720,
                members =
                {
                    "Alexey \"KaranaK\" Pyatov",
                    "Evgeniy Zaikin",
                    "Igor Vitkovskiy",
                    "Eldar Zakirov"
                }
            },
            {
                subtitle = "3D Artists",
                colWidth = 720,
                members =
                {
                    "Sergey Zinoviev",
                    "Dmitry Sorokin",
                    "Andrius Balciunas",
                    "Yuri Mironov",
                    "Martynas Cesnauskas",
                    "Arnas Gaudutis",
                    "Vladimir Mironov",
                    "Aleksandr Kirilenko",
                    "Sergey Stepanchikov",
                    "Alexander Surnin",
                    "Goran Sadojevich",
                    "Arminas Didziokas",
                    "Oskars Pavlovskis"
                }
            },
        }
    },
    {
        title = "Fox3D Studios",
        autoTime = 9,
        groups =
        {
            {
                subtitle = "Additional 3D Artists",
                colWidth = 720,
                members =
                {
                    "Pavel Lipnyagov",
                    "Daniil Spivak",
                    "Alexey Vasiliev",
                    "Maxim Vigovskoy",
                    "Yuri Ekimov",
                    "Pavel Petrenko",
                    "Andrius Gricius",
                    "Oleg Linkov",
                    "Aleksandr Bursov",
                    "Alexander Arseniev",
                    "Alexander Siutkin",
                    "Alexander Stepanchikov",
                    "Alexey Nazarov",
                    "Alexander Boluzhenkov",
                    "Sergey Ivanchenko",
                    "Vladimir Andropov",
                    "Sergey Ponomarenko",
                    "Andrey Kultishev",
                    "Alexander Ignatenko",
                    "Dmitry Shlyakov",
                    "Andrew Belkov",
                    "Vladimir Zirianov",
                    "Andrew Maximov",
                    "Vadim Rogov",
                    "Alisher Mirzoev",
                    "Alvydas Jatkialo"
                }
            }
        }
    }, --end Fox3d

    {
        title = "Early Team",
        autoTime = 6,
        style = "bold",
        members = 
        {
            "Matt Regan (Art)",
            "Roald Braathen (Environment Art)",
            "Keith Duke-Cox (Environment Art)",
            "Philip Klevestav (Environment Art)",
            "Jason Lange (Environment Art)",
            "Brandon Mauro (Level Design)",
            "Andrew \"KungFuSquirrel\" Weldon (Level Design)",
            "Marc Delorme (Programming Intern)",
            "Henry Matthes (Programming)",
            "Kurt Miller (Programming)",
            "Andrew Spiering (Programming)",
        }
    },

    {
        title = "Art Bully Productions, LLC",
        autoTime = 5,
        style = "bold",
        members = 
        {
            "Marcus Dublin (Co-Founder / Art and Project Director)",
            "Alan Van Ryzin (Co-Founder / Art and Project Director)",
            "Evan Herbert",
            "Ivan Jankovic",
            "Mashru Mishu",
            "Alex Van Ryzin",
            "Mark Vick",
            "Jeremy Wynn",
            "Shaddy Safadi (Concept Art, http://www.shaddyconceptart.com/ )",
            "Jim Ingraham (User interface, http://input-labs.com/ )"
        }
    },

    {
        title = "Additional Programming",
        autoTime = 5,
        style = "bold",
        members = 
        {
            "Matt \"MetaMatt\" Calabrese",
            "Thomas \"fsfod\" Fransham",
            "Jon Heiner",
            "Mats \"Matso\" Olsson",
            "Marc Newton"
        }
    },

    {
        title = "Additional Mapping",
        autoTIme = 4,
        style = "bold",
        members = 
        {
            "Luke \"Loki\" Drabble (Level Design - Kodiak and Derelict)",
            "Juanjo \"Mendasp\" Alfaro (Summit and Veil updates)"
        }
    },

    {
        title = "Playtesting / Quality Assurance",
        autoTime = 9,
        groups = 
        {
            {
                subtitle = "Lead Playtesters",
                colWidth = 750,
                members =
                {
                    "Scott \"Obraxis\" MacDonald",
                    "Chris \"Ironhorse\" Gates",
                    "Dillon \"WasabiOne\" Savage",
                    "Thomas \"acidrain\" Loupe",
                    "Ari \"Jiriki\" Timonen",
                    "Teagan \"Narfwak\" Argiro",
                    "Cédric \"Explosif.be\" Timmermans",
                    "Laura \"Decoy\" Morris"
                }
            },
            {
                subtitle = "Deputy Playtest Leads",
                colWidth = 750,
                members =
                {
                    "Martin \"Kouji_San\" Borgman",
                    "Mike \"ScardyBob\" Noon",
                    "Elyse \"SabaHell\" Collins",
                    "Beat \"Asraniel\" Wolf",
                    "Matt \"Zavaro\" Allbright"
                }
            },
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Playtesters",
                colWidth = 750,
                members =
                {
                    "Jan \"EagleEye\"",
                    "Taylor \"hampton\"",
                    "Taylor \"hampton\"",
                    "Nathan \"pairdime\"",
                    "Torsten \"Raza\"",
                    "Jesse \"Nordic\" Adams",
                    "Devin \"Lazer\" Afshin",
                    "Juanjo \"Mendasp\" Alfaro",
                    "Keating Allen",
                    "Gyula Andrási",
                    "Brian \"Samusdroid\" Arneson",
                    "Andy \"DJ Splendid\" B",
                    "Skyler \"Redford\" Barnes",
                    "Michiel \"Flaterectomy\" Barten",
                    "Andreas \"Furs\" Begemann",
                    "David \"Davil\" Bembenek",
                    "Fabian \"Murdoc\" Beneking",
                    "Joel \"NinjaPirateAssassin\" Benham",
                    "Peter \"Kalessin\" Bennett",
                    "Geoffrey \"Atlan\" Blanpain",
                    "Mattijs \"Motig\" Blokdijk",
                    "Jesper \"Flowbar\" Blommaskog",
                    "Richard \"MaKkApAkKa\" Booth",
                    "Sam \"Zinkey\" Boyce",
                    "Catherine \"Prinny\" Brace",
                    "Colin \"Coaleh\" Bradley",
                    "Matthew Breit",
                    "Robin T. \"wltrs\" Brinkestål",
                    "Matthew \"Farren\" Brown",
                    "Lee \"Confused!\" Brunjes",
                    "Scott C",
                    "Matt \"MetaMatt\" Calabrese",
                    "Jarrod \"Caboose\" Cary",
                    "Devon \"Delta Centauri\" Ceru",
                    "Andrew \"Zaloko\" Childress",
                    "Alexander \"TechnIckS\" Christian",
                    "Joseph \"MostlySilent\" Cleary",
                    "Dave \"Var\" Conroy",
                    "Chris \"Rebel\" Cooper",
                    "Nick \"MrYiff\" Cunningham",
                    "Grant \"frost\" Cunningham",
                    "Alasdair \"Toothy\" Dawson",
                    "Christopher \"OmegaNS2\" de la Iglesia",
                    "Maxime \"Astamarr\" Delerin",
                    "Michael \"civ\" Delos",
                    "Jens \"dePARA\" Deparade",
                    "Dave Dixon",
                    "James \"Volcano\" Doyle",
                    "Luke \"Loki\" Drabble",
                    "Carlchristian \"slizzared\" Eckert",
                    "James \"sherpa\" Elston",
                }
            },
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Playtesters",
                colWidth = 750,
                members =
                {
                    "Kyle \"linksysrouter\" Engstrom",
                    "Jamal \"Semihandy\" Fanaian",
                    "Naveed \"PersianImm0rtal\" Farbakhsh",
                    "Jon Finger",
                    "Felix \"PsiWarp\" Fok",
                    "Kane Forrester",
                    "Øivind K. \"Fana\" Foss",
                    "Thomas \"fsfod\" Fransham",
                    "Alexander \"GohanZeta\" Frerich",
                    "Richard \"Argi\" Fuller",
                    "Roeland \"Neoken\" Gallein",
                    "Daniel \"troops\" Gallimore",
                    "John \"shiv\" Gann",
                    "Nils \"Pampelmuse\" Garbe",
                    "Ryan \"Tin-Foil Helmet\" Gholson",
                    "Brock \"McGlaspie\" Gillespie",
                    "Joe \"doeseph\" Glynn",
                    "Sam \"au.zilla\" Goldhaber",
                    "John \"Genova\" Granier",
                    "Sascha \"Sascha\" Groß",
                    "James \"twiliteblue\" Gu",
                    "Simon \"_INTER_\" Gwerder",
                    "James \"Pyrokid\" H",
                    "Stephen \"current1y\" Harner",
                    "Trevor \"BeigeAlert\" Harris",
                    "Damien \"Onos Ate Me\" Hauta",
                    "Janne \"Skie\" Helkala",
                    "Christian \"Enceladus\" Hemesath",
                    "Mike \"Dusk\" Hennessy",
                    "Brandon \"Kronos\" Hight",
                    "Felix \"Lithen\" Hindemo",
                    "Doug \"Quovatis\" Hoffman",
                    "Oskar \"Ramblemoe\" Holmberg",
                    "Jonny \"Tekoppen\" Holmvall",
                    "Howard \"Howser\" Hopkins",
                    "Michael \"StripeTails\" Hornburg",
                    "Dennis \"CrushaK\" Iffländer",
                    "Jonathan \"Warboy\" Imler",
                    "Joshua \"bawNg\" J",
                    "Anders \"Brewte\" Järleberg",
                    "Meurig \"Smaug\" Llyr Jenkins",
                    "Kenneth \"fRiJeC\" Jensen",
                    "Alex \"Temp\" Jeremy",
                    "Harry \"Delph\" Jones",
                    "Jennifer \"Feathermonster\" Kanne",
                    "Elias \"tactic\" Karlstrand",
                    "Lennart \"Nakorson\" Kessler",
                    "Ashlynn \"Sloppy Kisses\"",
                    "John \"Petros Ichor\" Knapp",
                    "Kevin \"Its Super Effective\" Ko" --FIXME apostrophe "It's" causes font to change
                }
            }
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Playtesters",
                colWidth = 750,
                members = 
                {
                    "Brian de Koning",
                    "Peter \"kormendi\" Kormendi",
                    "Henry Kropf",
                    "Hamza \"BigImp\" Kubba",
                    "Josh \"Internets\" L",
                    "Travis \"Xerond\" Ladner",
                    "Florian \"SysLd\" Lamari",
                    "Matt \"Dirm\" Landis",
                    "Logan \"MGS-3\" Lavigne",
                    "Brecht \"Brechtos\" Lecluyse",
                    "Peter \"Dhova\" Lehmuth",
                    "Jon \"Sloth\" Lent",
                    "Jon \"PJ Maybe\" Leslie-Smith",
                    "Murilo \"Oxi\" Lino",
                    "Juha \"quazilin\" Lipsonen",
                    "Chris \"156Scottie\" Loar",
                    "Taylor \"Gibs\" Lovejoy",
                    "David \"Remedy\" Lucas",
                    "Zachary \"Computerquip\" Lund",
                    "Mike \"Ink\" M",
                    "Andrew \"Syknik\" M",
                    "Juho \"Garo\" Mäkinen",
                    "James \"prevert-maximus\" Malin",
                    "Travis \"pRiNcEkAhUnA\" Maner",
                    "Justin \"IAmSecretSpy\" Marlin",
                    "Brendan \"BreadMan\" Mauro",
                    "William \"Maxamus\" Mccracken",
                    "Olof \"Agiel\" Millberg",
                    "Ryan \"eh?\" Mitchell",
                    "Szabolcs \"fleetcommand\" Molnár",
                    "Brian \"ÒraNg?\" Molyneaux",
                    "Christian \"Shameless\" Moore",
                    "Zak \"zipy124\" Morgan",
                    "Ryan Moulton",
                    "Travis \"Tornel\" Mullikin",
                    "Jay \"Slycaster\" Murphy",
                    "Chris \"MeatMachine\" Napier",
                    "Dennis \"Tquila\" Bækgaard Nielsen",
                    "Antti \"zups\" Niemi",
                    "Christian \"Grimfang\" Noergaard",
                    "Brian \"lanternx\" Noriega",
                    "Adam \"Kmart-\" Nuhaily",
                    "Mark \"Rising\" O",
                    "Ryan \"Bohdai\" O’Dell",
                    "Joey \"vizioNz\" OD",
                    "Juha \"Nadyl\" Oinonen",
                    "Jaakko \"Zeikko\" Ojalehto",
                    "Jim \"JazzX\" Olson",
                    "Mats \"Matso/Grimjack\" Olsson",
                    "Martin \"Bleu\" Ostera",
                    "Logan \"Rohadnis\" Pennington"
                }
            }
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Playtesters",
                colWidth = 750,
                members = 
                {
                    "Dy \"Zefram\" Phan",
                    "Henrique \"nican\" Polido",
                    "Ned \"MonsE\" Pyle",
                    "Chris \"Tempest\" Rahn",
                    "Samuli \"OddOneOut\" Raivio",
                    "Brian \"devicenull\" Rak",
                    "Benjamin \"Ben-Jammin\" Rall",
                    "Maxime \"ahrz\" Raynaud",
                    "James \"xconpirisist\" Read",
                    "Alex \"Vlad\" Richards",
                    "Adam \"Supernorn\" Riches",
                    "Philipp \"Jaqarll\" Rieth",
                    "Philipp \"Jaqarll\" Rieth",
                    "Josh \"joshhhy\" Robbins",
                    "Artur \"CarNagE\" Rodak",
                    "Nicholas \"CloneDeath\" Rodine",
                    "Petter \"tankefugl\" Rønningen",
                    "Beranger\"Regnareb\" Roussel",
                    "Joel Rubicam",
                    "Grétar Már \"Grissi\" Rúnarsson",
                    "Joakim \"eoy\" Runeberg",
                    "Leon \"Janos\" Rusiecki",
                    "Petri \"vartija\" Ryhänen",
                    "Adam \"inveigle\" Salinas",
                    "Emil \"GISP\" Symes Schrøder",
                    "Ryan Scott",
                    "Ryan \"rws\" Seavert",
                    "Lennart \"Anzestral\" Seiffert",
                    "Jedi SheeP",
                    "Alexei \"Roflcopter\" Short",
                    "Felipe \"Zoc\" Silveira",
                    "Linus \"thelinx\" Sjögren",
                    "Charlie \"NeoTheOne\" Skog",
                    "Tom \"Arkanti\" Spratt",
                    "Peter \"Wombat\" Møller Stephansen",
                    "Jeff \"Ulfsark\" Stevens",
                    "Johannes \"driest\" Stuettgen",
                    "Min \"SpaPal\" Soo Suh",
                    "Galen \"dd77\" Surlak",
                    "Daniel \"neighbs\" Tarantino",
                    "Nathan \"Moo Jr\" Taylor",
                    "Brett \"Chimp\" Thurman",
                    "Tim \"rad4christ\" Timmons",
                    "Scott \"sp3cia1? Tongue",
                    "Blasphemy \"Blasphemy\" Townsend",
                    "Kevin \"gliss\" Tran",
                    "Paul Traylor",
                    "Lou \"FLuX\" Trujillo",
                    "Steve \"G=Lock\" Tuns",
                    "Boris \"RejZor\" Urbancic",
                    "Mark \"Angelusz\" van de Pol",
                }
            }
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 7,
        groups = 
        {
            {
                subtitle = "Playtesters",
                colWidth = 750,
                members =
                {
                    "Daan \"Daan\" van Yperen",
                    "John \"Ninja Canyon Monkey\" Warburton",
                    "Simon \"waxxan\" Wäreby",
                    "Andrew \"Ulmont\" Weathers",
                    "Ben \"Vodka\" Webster",
                    "Daniel \"Murray\" Wendt",
                    "Colin \"phoenixbbs\" Wilson",
                    "Sam \"The_Epitome\" Wolff",
                    "Mikko \"Nde\" Y",
                    "Auke \"Zaggy\" Zaagman",
                    "Marco \"RuneStorm\" Axer",
                    "asmodee",
                    "citixen",
                    "FluffyKitten",
                    "KuddlyKalli",
                    "Rafa",
                    "Shakewell",
                    "Sonder",
                    "TomTom",
                    "Toughsox",
                    "xtcmen",
                    "Paul \"PaulWolfe\" Wolfe",
                    "Jamie \"Kash\" Sloan",
                    "Kevin \"Steelcap\" Kicklighter",
                    "Stephen \"Uncle Bo\" Ryan",
                    "Alex \"TriggerHappyBro\" Hollifield",
                    "Jon \"Trilantis\" Voss",
                    "David \"ieptbarakat\" Lewis",
                    "Ty \"Noky\" Emmert"
                }
            }
        }
    },
    {
        title = "Playtesting / Quality Assurance",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Map Tester Leads",
                colWidth = 650,
                members =
                {
                    "Chris \"Bitey\" Mohn",
                    "Amanda \"rantology\" Diaz",
                    "Dillon \"WasabiOne\" Savage"
                }
            },
            {
                subtitle = "Map Testers",
                colWidth = 620,
                members =
                {
                    "Matthew \"Dragon\" Kreider",
                    "Trent \"JuCCi-PuCCi\" Rideout",
                    "Alec \"Locklear\" Harter",
                    "James \"Locke\" Bates III",
                    "Joel \"bEEb\" Rader",
                    "Kevin \"gliss\" Tran",
                    "GORGEous",
                    "Darin \"xorex\" Tyacke",
                    "David \"[TGL]Thunderhorse\" Warren",
                    "Rehevkor",
                    "Ryne Whitehill",
                    "Richard \"Dusteh\" Jessup",
                    "Thomas \"Tweadle\" Eagle",
                    "Naveed \"PersianImm0rtal\" Farbakhsh",
                    "Bradley \"Mike DITKA\" Fry",
                    "Steven \"Shaker\" Bouwkamp",
                    "Dustin \"Xclen\" Elmore",
                    "Stefan \"Flip\" Jankowski",
                    "Bryan \"Vizzy\" Dodd",
                    "James \"H3lix\" Quigley",
                    "Edi \"ArcLight\" Škofljanec",
                    "David \"IeptBarakat\" Lewis",
                    "Alex \"Virsoul\" Sawchuk",
                    "Ashton \"Martigen\" Mills",
                    "Christopher \"Golden\" Brown",
                    "Kevin Trono",
                    "Terrence Donnelly"
                }
            },
            {
                subtitle = "Balance Team",
                colWidth = 600,
                members =
                {
                    "Grétar Már \"Grissi\" Rúnarsson",
                    "Amanda \"rantology\" Diaz",
                    "GORGEous",
                    "Dennis \"CrushaK\" Iffländer",
                    "Dennis \"Blind\" P.",
                    "Tane",
                    "vidar \"Valk huri\" Heidarsson",
                    "Blake \"Jekt\" luetkens",
                    "Aaron \"mf-\" Sutton",
                    "Nicholas \"ezekel\" Themelis",
                    "Øivind K. \"Fana\" Foss",
                    "Jeremy \"Elodea\" Vun",
                    "Tobias",
                    "Christopher \"Golden\" Brown",
                    "Lucas \"acedude\" Nowaczek",
                    "Alex \"Virsoul\" Sawchuk",
                    "Chris \"Bitey\" Mohn",
                    "Matthew \"Dragon\" Kreider"
                }
            }
        }
    }, --End playtesting/qa

    {
        title = "Community Development Team",
        autoTime = 12,
        groups = 
        {
            {
                subtitle = "Project Leads",
                colWidth = 750,
                members =
                {
                    "Dillon \"WasabiOne\" Savage",
                    "Scott \"Obraxis\" MacDonald",
                    "Brock \"McGlaspie\" Gillespie"
                }
            },
            {
                subtitle = "Developers",
                colWidth = 1150,
                forceNewline = true,
                members =
                {
                    "Ryan \"Moultano\" Moulton (Skill System Algorithm)",
                    "Thomas \"fsfod\" Fransham (Bug fixes and Engine Development, 64-bit Upgrade)",
                    "Mats \"Matso\" Olsson (Bug fixes and Engine Development)",
                    "Brian \"Samusdroid\" Arneson (Bug fixes and Gameplay Programming)",
                    "Zachary \"Computerquip\" Lund (Linux Programming and Bug Fixes)",
                    "Daniel \"Murray\" Wendt (Linux Programmer)",
                    "Juanjo \"Mendasp\" Alfaro (Bug fixes, UI Features, Map Touching)",
                    "Sebastian \"Ghoul\" Schuck (Bug Fixes)",
                    "Skyler Clark (Bug Fixes and Gameplay Programming)",
                    "Jean-Baptiste \"Katzenfleisch\" Laurent (Gameplay Programmer)",
                    "Andrew \"Ulmont\" Weathers (Texture Optimization)",
                }
            },
        }
    },
    {
        title = "Community Development Team",
        autoTime = 12,
        groups =
        {
            {
                subtitle = "Playtesting Leads",
                colWidth = 750,
                members =
                {
                    "Teagan \"Narfwak\" Argiro (Lead)",
                    "Laura \"Decoy\" Morris (NA Co-Lead)",
                    "Beat \"Asraniel\" Wolf (EU Lead)",
                    "Matt \"Zavaro\" Allbright (NA Deputy)"
                }
            },
            {
                subtitle = "Other",
                colWidth = 1150,
                forceNewline = true,
                members =
                {
                    "Chris \"Ironhorse\" Gates (Tech Support, Squad 5 Lead, Quality Assurance)",
                    "Dy \"Zefram\" Phan (Feedback)",
                    "Amanda \"Rantology\" Diaz (Art and GUI Design)",
                    "Sebastian \"Seb\" Oswell (Video Producer)",
                    "Todd \"Comprox\" Calder (Forum Management)",
                    "Luke \"Loki\" Drabble (Map Developer and SCC Community Relations)",
                    "Christopher \"Golden\" Brown (Competitive Feedback and Balance Discussion)"
                }
            }
        }
    },

    {
        title = "Reinforcement Special Contributors",
        autoTIme = 10,
        members =
        {
            "@hugh_jeremy",
            "Ashton Mills",
            "Brock \"McGlaspie\" Gillespie",
            "Darrin Frankovitz",
            "Emil \"GISP\" Symes Schrøder",
            "Explosif.be.be",
            "GeorgiCZ",
            "Incredulous Dylan",
            "Lachdanan",
            "Logan \"MGS-3\" Lavigne",
            "Mazza",
            "MichaAﾫl Debrieu",
            "OwNzOr",
            "Patrick8675",
            "[TWAT] Bonkers",
            "Paul \"KungFuDiscoMonkey\" Traylor",
            "Petri \"vartija\" RyhAﾤnen",
            "Railo",
            "Richard \"Brackhar\" Hough",
            "Sam \"Zinkey\" Boyce",
            "Steven Glass",
            "Tex",
            "WDI",
            "zaggynl",
            "Alex \"Virsoul\" Sawchuk"
        }
    },

    {
        title = "Development Babies",
        autoTime = 4,
        members =
        { 
            "Finn McGuire"
        }
    },

    {
        title = "Special Thanks",
        colWidth = 1115,
        autoTime = 18,
        members =
        {
            "Scott \"Obraxis\" MacDonald (Quality Assurance Lead)", 
            "Harry \"Puzl\" Walsh",
            "Todd \"Comprox\" Calder (Community Lead / Customer Service)",
            "Dillon \"WasabiOne\" Savage (Casting, PT, Merch, PAX, Live Events)",
            "Chris \"Ironhorse\" Gates (QA / Technical Support)",
            "Tim Bowman (Additional Animation)",
            "Evan Mead (Additional Animation)",
            "Jon \"Huze\" Hughes (Spectator System)",
            "Michael \"psyk0man\" Kahl (ns2_summit)",
            "Shawn Snelling (ns2_veil)",
            "Grétar Már \"Grissi\" Rúnarsson",
            "Adam \"Supernorn\" Riches (Minimap Icons)",
            "Kevin \"Its Super Effective\" Ko (Tip clip videos)", --FIXME apostrophe in "It's" messes with the font-family somehow
            "Bill Wang (Perfect World)",
            "Matt Wyatt (Perfect World)",
            "Leslie Keil (Hanson Bridgett)",
            "Richard Kain",
            "Colin Wiel",
            "Ira Rothken",
            "Matthew Le Merle",
            "Harley Huggins",
            "Elyse \"SabaHell\" Collins",
            "Kouji (Moral support)",
            "Jason Ruymen",
            "Team Archaea",
            "Valve",
            "Humble Bundle",
            "Our tireless forum admins",
            "Our competitive map playtesters",
            {
                style = "bold",
                value = "Our amazing community that never stopped believing."
            }
        }
    },

    --Have "special" logo / final page?
}

