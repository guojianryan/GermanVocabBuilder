from lib import *

# an -----------------------------------------------------------------------
full({
 "word": {"headword": "an", "partOfSpeech": "preposition (dative or accusative); separable prefix",
  "pronunciation": {"respelling": "AHN", "ipa": "an", "notes": "Short a."},
  "meaning": "at, on (a vertical surface or edge); on (days and dates)",
  "shortDefinition": "Says where something is next to or touching, and when something happens."},
 "intro": {"title": "At the station, on Monday", "paragraphs": [
  "An covers a lot of what English does with 'at' and 'on': am Bahnhof (at the station), an der Wand (on the wall), am Montag (on Monday). It's also one of the most common verb prefixes: anrufen, ankommen, anfangen."]},
 "etymology": {"title": "Where it comes from",
  "summary": "An is the same word as English 'on', and a close cousin of 'at' in many uses.",
  "cognates": [{"word": "on", "language": "English"}, {"word": "aan", "language": "Dutch"}]},
 "tables": [{"title": "an + dem = am", "intro": "With masculine and neuter nouns in the dative, an and dem merge into am. You'll see am far more often than an dem.",
  "columns": ["where (dative)", "where to (accusative)"],
  "rows": [
   {"label": "masculine", "cells": ["a|m| Tisch", "an |den| Tisch"]},
   {"label": "feminine", "cells": ["an |der| Wand", "an |die| Wand"]},
   {"label": "neuter", "cells": ["a|m| Fenster", "an|s| Fenster"]}],
  "notes": ["Where something is: dative (am, an der). Where it's going: accusative (an den, an die, ans).",
            "Days, parts of the day and dates always use am: am Montag, am Abend, am 3. Mai."]}],
 "wordFamily": [
  {"german": "am Montag", "english": "on Monday", "type": "phrase"},
  {"german": "am Abend", "english": "in the evening", "type": "phrase"},
  {"german": "an sein", "english": "to be on (light, TV)", "type": "phrase"},
  {"german": "anrufen, ankommen, anfangen", "english": "verbs with the prefix an-", "type": "separable verbs"}],
 "keyTrap": {"title": "The big trap: in, an or auf for days and places?",
  "explanation": "English says 'on Monday' and 'at the station'. German uses am for both, but in for months and seasons.",
  "wrong": {"german": "Ich komme an Montag.", "verdict": "Days need am, the short form of an dem."},
  "correct": [
   {"german": "Ich komme am Montag.", "literal": "I come on-the Monday.", "note": "Days: am."},
   {"german": "Wir treffen uns am Bahnhof.", "literal": "We meet at-the station.", "note": "At a place you stand next to: am."},
   {"german": "Ich habe im Mai Urlaub.", "literal": "I have in-the May holiday.", "note": "Months: im, not am."}]},
 "commonMistakes": [
  {"title": "an or auf?", "explanation": "An is for vertical surfaces and edges, auf for horizontal surfaces you can put things on.",
   "examples": [{"german": "Das Bild hängt an der Wand.", "english": "The picture is hanging on the wall.", "highlight": "an"},
                {"german": "Das Buch liegt auf dem Tisch.", "english": "The book is on the table.", "highlight": "auf"}]},
  {"title": "Near water", "explanation": "By the sea, a lake or a river is an: am Meer, am See, am Rhein.",
   "wrong": "Wir machen Urlaub bei dem Meer.", "correct": "Wir machen Urlaub am Meer."}],
 "sampleSentences": [
  s("Fahren Sie an der nächsten Ampel rechts.", "Turn right at the next traffic lights.", ["an"]),
  s("Am Wochenende habe ich frei.", "I'm off at the weekend.", ["Am"]),
  s("Er sitzt am Fenster.", "He's sitting by the window.", ["am"]),
  s("Ich hänge das Foto an die Wand.", "I'm hanging the photo on the wall.", ["an", "die"]),
  s("Mach bitte das Licht an.", "Please turn the light on.", ["an."])],
 "forms": ["am", "ans", "an dem", "an der"],
 "memoryHook": "An = on, at, next to. Days and places you stand at take am: am Montag, am Bahnhof.",
 "signOff": "Bis am Montag!"},
 [q_choice("Ich habe ___ Freitag Zeit.", ["an", "am", "im"], "am", "Days: am."),
  q_choice("Wir fahren im Sommer ___ Meer.", ["ans", "am"], "ans", "Where to (moving): accusative, an + das = ans."),
  q_choice("Wir wohnen direkt ___ Meer.", ["ans", "am"], "am", "Where (location): dative, an + dem = am."),
  q_choice("Das Poster hängt ___ der Wand.", ["an", "auf"], "an", "A vertical surface: an."),
  q_fill("Ich komme ___ 5. Juni. (on the 5th of June)", "am", "Ich komme am 5. Juni.", "Dates use am.")])

# anbieten -----------------------------------------------------------------
card("anbieten", "separable verb", "AHN-bee-ten", "ˈanbiːtn̩", "to offer",
 [s("Darf ich Ihnen etwas zu trinken anbieten?", "May I offer you something to drink?", ["anbieten?"]),
  s("Der Supermarkt bietet heute Erdbeeren an.", "The supermarket is offering strawberries today.", ["bietet", "an."]),
  s("Diese Jacke ist im Angebot.", "This jacket is on special offer.", ["Angebot."])],
 [q_fill("Darf ich dir einen Kaffee ___?", "anbieten", "Darf ich dir einen Kaffee anbieten?", "After darf, the verb stays whole at the end."),
  q_fill("Die Firma ___ mir einen Job an.", "bietet", "Die Firma bietet mir einen Job an.", "Bieten in second place, an at the end."),
  q_choice("'Im Angebot' means…", ["on special offer", "sold out"], "on special offer", "Das Angebot: the offer."),
  q_choice("Wem bietest du etwas an? Ich biete ___ einen Tee an. (him)", ["ihn", "ihm"], "ihm", "The person you offer to is in the dative."),
  q_choice("___ Angebot", ["der", "die", "das"], "das", "Das Angebot, plural die Angebote.")],
 "Bieten = to offer, an = toward. You hold it out toward someone. Im Angebot = on offer.",
 table=present(["biete … |an", "bietest … |an", "bietet … |an", "bieten … |an", "bietet … |an", "bieten … |an"], perfekt="hat angeboten"),
 family=[{"german": "das Angebot", "english": "offer; special offer", "type": "noun"},
         {"german": "im Angebot", "english": "on special offer", "type": "phrase"}],
 forms=["biete an", "bietet an", "angeboten", "bot an", "Angebot", "Angebote"])

# ander- -------------------------------------------------------------------
card("ander-", "adjective (always with an ending: andere, anderer, anderes)", "AHN-der-uh", "ˈandəʁə", "other, different",
 [s("Ich möchte die andere Jacke.", "I'd like the other jacket.", ["andere"]),
  s("Haben Sie das auch in einer anderen Farbe?", "Do you have it in a different colour too?", ["anderen"]),
  s("Das ist etwas ganz anderes.", "That's something completely different.", ["anderes."]),
  s("Die anderen kommen später.", "The others are coming later.", ["anderen"])],
 [q_choice("Ich nehme die ___ Tasche. (the other bag)", ["andere", "anderen", "anderer"], "andere", "Die + feminine: andere."),
  q_choice("Das ist etwas ___. (something different)", ["andere", "anderes"], "anderes", "Etwas + adjective takes -es."),
  q_fill("Wo sind die ___? (the others)", "anderen", "Wo sind die anderen?", "Plural after die: anderen."),
  q_choice("Haben Sie eine ___ Größe? (a different size)", ["andere", "anderen"], "andere", "Eine + feminine: andere."),
  q_choice("Ander- means…", ["other, different", "again", "and"], "other, different", "Same root as English 'other'.")],
 "Ander- is English 'other' with an n. It never stands bare: it always has an ending, like andere, anderes, anderen.",
 ety={"summary": "Ander- and English 'other' come from the same old Germanic word.",
      "cognates": [{"word": "other", "language": "English"}, {"word": "ander", "language": "Dutch"}]},
 tip={"title": "Always with an ending", "explanation": "The bare form ander is never used on its own.",
      "wrong": "die ander Jacke", "correct": "die andere Jacke"},
 forms=["andere", "anderer", "anderes", "anderen", "anderem"])

# anfangen -----------------------------------------------------------------
full({
 "word": {"headword": "anfangen", "partOfSpeech": "separable verb",
  "pronunciation": {"respelling": "AHN-fahng-en", "ipa": "ˈanfaŋən", "notes": "The ng is one sound, as in 'singer', not 'finger'."},
  "meaning": "to begin, to start",
  "shortDefinition": "To start something, or for something to start."},
 "intro": {"title": "Wann fängt der Film an?", "paragraphs": [
  "Anfangen is the everyday word for 'to start'. It splits like every an- verb, and it has an umlaut surprise: du fängst, er fängt."]},
 "etymology": {"title": "Where it comes from",
  "parts": [{"part": "an", "meaning": "at, on"}, {"part": "fangen", "meaning": "to catch"}],
  "literalMeaning": "to catch on to",
  "summary": "You start a task by catching hold of it.",
  "bonus": {"word": "der Anfang", "meaning": "the beginning", "note": "Am Anfang: at the beginning. Anfang Juli: at the beginning of July."}},
 "tables": [{"title": "How it splits", "columns": ["present", "past (Perfekt)"],
  "rows": [
   {"label": "ich", "cells": ["fange … |an", "habe … |angefangen"]},
   {"label": "du", "cells": ["fängst … |an", "hast … |angefangen"]},
   {"label": "er, sie, es", "cells": ["fängt … |an", "hat … |angefangen"]},
   {"label": "wir", "cells": ["fangen … |an", "haben … |angefangen"]},
   {"label": "ihr", "cells": ["fangt … |an", "habt … |angefangen"]},
   {"label": "sie, Sie", "cells": ["fangen … |an", "haben … |angefangen"]}],
  "notes": ["Du fängst and er fängt get an umlaut."]}],
 "wordFamily": [
  {"german": "der Anfang", "english": "beginning", "type": "noun"},
  {"german": "beginnen", "english": "to begin (a bit more formal)", "type": "verb"},
  {"german": "aufhören", "english": "to stop", "type": "separable verb"}],
 "keyTrap": {"title": "The big trap: starting with something",
  "explanation": "To say what you're starting, German often uses mit + dative.",
  "wrong": {"german": "Ich anfange um acht mit der Arbeit.", "verdict": "The an has to go to the end."},
  "correct": [
   {"german": "Ich fange um acht mit der Arbeit an.", "literal": "I catch at eight with the work on.", "note": "Starting an activity: mit + dative."},
   {"german": "Der Kurs fängt am Montag an.", "literal": "The course catches on Monday on.", "note": "Something starts: no object."}]},
 "commonMistakes": [
  {"title": "Don't forget the umlaut", "explanation": "For du and er, sie, es: fängst, fängt.", "wrong": "Er fangt an.", "correct": "Er fängt an."},
  {"title": "Beginning of a month", "explanation": "Anfang + month, without a preposition.",
   "examples": [{"german": "Anfang Mai fahre ich weg.", "english": "I'm going away at the beginning of May.", "highlight": "Anfang"}]}],
 "sampleSentences": [
  s("Wann fängt der Film an?", "When does the film start?", ["fängt", "an?"]),
  s("Der Unterricht fängt gleich an.", "The lesson is about to start.", ["fängt", "an."]),
  s("Ich habe mit dem Sport angefangen.", "I've started doing sport.", ["angefangen."]),
  s("Am Anfang war alles neu.", "At the beginning everything was new.", ["Anfang"])],
 "forms": ["fange an", "fängst an", "fängt an", "angefangen", "fing an", "Anfang"],
 "memoryHook": "An + fangen = catch on to it. Er fängt an: he's catching on, he's starting.",
 "signOff": "Fang einfach an!"},
 [q_fill("Der Film ___ um 20 Uhr an.", "fängt", "Der Film fängt um 20 Uhr an.", "Fangen gets an umlaut for er, sie, es.", accept=["faengt"]),
  q_fill("Wann hast du mit dem Deutschkurs ___?", "angefangen", "Wann hast du mit dem Deutschkurs angefangen?", "An-ge-fangen."),
  q_choice("___ Juli habe ich Urlaub. (At the beginning of July)", ["Anfang", "Am Anfang"], "Anfang", "Anfang + month, no preposition."),
  q_choice("The opposite of anfangen is…", ["aufhören", "aufstehen"], "aufhören", "Aufhören: to stop."),
  q_choice("Ich fange morgen ___ dem Training an.", ["mit", "von"], "mit", "Starting an activity: mit + dative.")])

# anklicken ----------------------------------------------------------------
card("anklicken", "separable verb", "AHN-klik-en", "ˈanklɪkn̩", "to click on",
 [s("Klicken Sie hier an.", "Click here.", ["Klicken", "an."]),
  s("Du musst dieses Feld anklicken.", "You have to click this box.", ["anklicken."]),
  s("Ich habe den Link angeklickt.", "I clicked the link.", ["angeklickt."])],
 [q_fill("Bitte ___ Sie das Bild an.", "klicken", "Bitte klicken Sie das Bild an.", "Klicken first, an at the end."),
  q_fill("Hast du den Button ___?", "angeklickt", "Hast du den Button angeklickt?", "An-ge-klickt."),
  q_choice("Which sentence is correct?", ["Ich anklicke den Link.", "Ich klicke den Link an."], "Ich klicke den Link an.", "An goes to the end."),
  q_choice("Du musst hier ___.", ["anklicken", "klicken an"], "anklicken", "After musst, the verb stays whole."),
  q_choice("Anklicken is used for…", ["computers and phones", "doors"], "computers and phones", "Clicking on screens.")],
 "Anklicken is English 'click' with an an-: you click on something.",
 table=present(["klicke … |an", "klickst … |an", "klickt … |an", "klicken … |an", "klickt … |an", "klicken … |an"], perfekt="hat angeklickt"),
 forms=["klicke an", "klickt an", "angeklickt"])

# ankreuzen ----------------------------------------------------------------
card("ankreuzen", "separable verb", "AHN-kroy-tsen", "ˈankʁɔɪ̯tsn̩", "to tick, to mark with a cross",
 [s("Bitte kreuzen Sie die richtige Antwort an.", "Please tick the right answer.", ["kreuzen", "an."]),
  s("Hier musst du 'ja' oder 'nein' ankreuzen.", "Here you have to tick 'yes' or 'no'.", ["ankreuzen."]),
  s("Ich habe das falsche Feld angekreuzt.", "I ticked the wrong box.", ["angekreuzt."])],
 [q_fill("Bitte ___ Sie die richtige Antwort an.", "kreuzen", "Bitte kreuzen Sie die richtige Antwort an.", "Kreuzen first, an at the end."),
  q_fill("Ich habe 'nein' ___.", "angekreuzt", "Ich habe 'nein' angekreuzt.", "An-ge-kreuzt."),
  q_choice("Ankreuzen comes from das Kreuz, which means…", ["cross", "circle", "line"], "cross", "German forms are often marked with a cross (X)."),
  q_choice("In a German exam you see 'Kreuzen Sie an'. You should…", ["mark the box", "write a sentence"], "mark the box", "Ankreuzen: mark with a cross."),
  q_choice("The eu in kreuzen sounds like…", ["oy in 'boy'", "oo in 'food'"], "oy in 'boy'", "Eu is always 'oy'.")],
 "Ankreuzen = put a Kreuz (cross) on it. On German forms you mark boxes with an X.",
 note="Eu sounds like 'oy' in 'boy'.", family=[{"german": "das Kreuz", "english": "cross", "type": "noun"}],
 forms=["kreuze an", "kreuzt an", "angekreuzt"])

# anmachen -----------------------------------------------------------------
card("anmachen", "separable verb", "AHN-makh-en", "ˈanmaxn̩", "to turn on, to switch on",
 [s("Mach bitte das Licht an!", "Please turn on the light!", ["Mach", "an!"]),
  s("Kannst du den Fernseher anmachen?", "Can you switch on the TV?", ["anmachen?"]),
  s("Ich habe die Heizung angemacht.", "I've turned the heating on.", ["angemacht."])],
 [q_fill("___ bitte das Radio an!", "Mach", "Mach bitte das Radio an!", "Command form: mach … an."),
  q_choice("The opposite of anmachen is…", ["ausmachen", "aufmachen"], "ausmachen", "Ausmachen: to turn off."),
  q_fill("Wer hat das Licht ___?", "angemacht", "Wer hat das Licht angemacht?", "An-ge-macht."),
  q_choice("Das Licht ist ___. (It's on.)", ["an", "auf"], "an", "Lights and devices: an sein, aus sein."),
  q_choice("Which sentence is correct?", ["Ich anmache den Computer.", "Ich mache den Computer an."], "Ich mache den Computer an.", "An goes to the end.")],
 "An = on. Anmachen = make it on. Ausmachen = make it off.",
 tip={"title": "an, aus, auf, zu", "explanation": "An and aus are for lights and machines. Auf and zu are for doors and windows.",
      "examples": [{"german": "Mach das Licht aus.", "english": "Turn the light off.", "highlight": "aus."},
                   {"german": "Mach das Fenster auf.", "english": "Open the window.", "highlight": "auf."}]},
 family=[{"german": "ausmachen", "english": "to turn off", "type": "separable verb"}, {"german": "an sein", "english": "to be on", "type": "phrase"}],
 forms=["mache an", "macht an", "angemacht"])

# (sich) anmelden ----------------------------------------------------------
card("(sich) anmelden", "separable, often reflexive verb", "AHN-mel-den", "ˈanmɛldn̩", "to register, to sign up",
 [s("Wo kann ich mich für den Kurs anmelden?", "Where can I sign up for the course?", ["mich", "anmelden?"]),
  s("Ich melde mich im Bürgeramt an.", "I'm registering at the citizens' office.", ["melde", "mich", "an."]),
  s("Bitte gehen Sie zur Anmeldung.", "Please go to reception.", ["Anmeldung."])],
 [q_choice("Ich melde ___ für den Kurs an.", ["mich", "mir"], "mich", "Sich anmelden: ich melde mich an."),
  q_fill("Hast du dich schon ___?", "angemeldet", "Hast du dich schon angemeldet?", "An-ge-meldet."),
  q_choice("At a doctor's practice, 'die Anmeldung' is…", ["the reception desk", "the waiting room"], "the reception desk", "Where you register when you arrive."),
  q_choice("You sign up ___ a course.", ["für", "an"], "für", "Sich für etwas anmelden."),
  q_choice("Which sentence is correct?", ["Ich anmelde mich.", "Ich melde mich an."], "Ich melde mich an.", "An goes to the end.")],
 "Melden = report. Sich anmelden = report yourself in: register. In Germany you anmelden your address within two weeks of moving.",
 tip={"title": "Don't forget mich", "explanation": "When you register yourself, it's reflexive.", "wrong": "Ich melde an.", "correct": "Ich melde mich an."},
 family=[{"german": "die Anmeldung", "english": "registration; reception desk", "type": "noun"},
         {"german": "sich abmelden", "english": "to deregister, to sign out", "type": "separable verb"}],
 forms=["melde an", "meldet an", "angemeldet", "Anmeldung", "anmelden"])

# Anrede -------------------------------------------------------------------
noun("Anrede", "f", "Anreden", "AHN-ray-duh", "ˈanʁeːdə", "form of address (how you greet someone, especially in writing)",
 [s("Vergessen Sie die Anrede nicht.", "Don't forget the greeting.", ["Anrede"]),
  s("Im Brief steht als Anrede: Sehr geehrte Frau Weber.", "The letter opens: Dear Ms Weber.", ["Anrede:"]),
  s("Mit Freunden ist die Anrede einfach: Liebe Anna.", "With friends the greeting is simple: Dear Anna.", ["Anrede"])],
 [q_choice("A formal letter to Frau Weber begins:", ["Sehr geehrte Frau Weber,", "Hallo Weber,"], "Sehr geehrte Frau Weber,", "Formal: Sehr geehrte/r."),
  q_choice("An email to your friend Tom begins:", ["Lieber Tom,", "Liebe Tom,"], "Lieber Tom,", "Masculine: Lieber. Feminine: Liebe."),
  q_choice("For a stranger or your boss, the usual Anrede is…", ["du", "Sie"], "Sie", "Sie is the formal 'you'.")],
 "Anrede = what you an-reden someone with: the words you address them with.",
 tip={"title": "Formal or friendly?", "explanation": "Formal letters: Sehr geehrte Frau …, Sehr geehrter Herr … . Friends: Liebe …, Lieber … .",
      "examples": [{"german": "Sehr geehrter Herr Klein,", "english": "Dear Mr Klein,", "highlight": "geehrter"},
                   {"german": "Liebe Maria,", "english": "Dear Maria,", "highlight": "Liebe"}]},
 family=[{"german": "reden", "english": "to talk", "type": "verb"}])

# Ansage -------------------------------------------------------------------
noun("Ansage", "f", "Ansagen", "AHN-zah-guh", "ˈanzaːɡə", "announcement (spoken)",
 [s("Hören Sie die Ansagen.", "Listen to the announcements.", ["Ansagen."]),
  s("Ich habe die Ansage am Bahnhof nicht verstanden.", "I didn't understand the announcement at the station.", ["Ansage"]),
  s("Die Ansage auf dem Anrufbeantworter ist sehr kurz.", "The message on the answering machine is very short.", ["Ansage"])],
 [q_choice("Where do you often hear an Ansage?", ["at the train station", "in a book"], "at the train station", "Spoken announcements."),
  q_fill("Ich habe die ___ nicht gehört. (announcement)", "Ansage", "Ich habe die Ansage nicht gehört.", "Die Ansage."),
  q_choice("Ansage comes from sagen, which means…", ["to say", "to see"], "to say", "An + sagen: something said out to people.")],
 "An + sagen = to say out loud to people: an announcement.",
 note="The s sounds like z.", family=[{"german": "sagen", "english": "to say", "type": "verb"}, {"german": "die Durchsage", "english": "announcement (over a loudspeaker)", "type": "noun"}])

# Anschluss ----------------------------------------------------------------
noun("Anschluss", "m", "Anschlüsse", "AHN-shloos", "ˈanʃlʊs", "connection (train, phone, internet)",
 [s("In Mannheim haben Sie Anschluss nach Stuttgart.", "In Mannheim you have a connection to Stuttgart.", ["Anschluss"]),
  s("Ich habe meinen Anschluss verpasst.", "I missed my connection.", ["Anschluss"]),
  s("Die Wohnung hat einen Internetanschluss.", "The flat has an internet connection.", ["Internetanschluss."])],
 [q_choice("Your train is late and you miss the next train. You missed your…", ["Anschluss", "Ausgang"], "Anschluss", "Anschluss: connection."),
  q_choice("Ich habe ___ Anschluss verpasst. (my)", ["mein", "meinen"], "meinen", "Masculine accusative: meinen."),
  q_choice("Which is a phone or internet connection?", ["der Anschluss", "die Ansage"], "der Anschluss", "Telefonanschluss, Internetanschluss.")],
 "Schließen = to close, to lock together. An Anschluss is where two things lock together: two trains, or your flat and the internet.",
 forms=["Anschlusses", "Anschlüssen"])

# an sein ------------------------------------------------------------------
card("an sein", "verb phrase", "AHN zine", "an zaɪn", "to be on (lights, machines)",
 [s("Das Licht ist noch an.", "The light is still on.", ["ist", "an."]),
  s("Ist der Computer an?", "Is the computer on?", ["Ist", "an?"]),
  s("Heute Nacht war der Fernseher die ganze Zeit an.", "Last night the TV was on the whole time.", ["war", "an."])],
 [q_choice("Das Radio ___ an.", ["ist", "hat"], "ist", "An sein: it uses sein."),
  q_choice("The opposite of 'Das Licht ist an' is…", ["Das Licht ist aus.", "Das Licht ist zu."], "Das Licht ist aus.", "An and aus for lights."),
  q_choice("Die Tür ist ___. (open)", ["an", "auf"], "auf", "Doors are auf or zu, not an."),
  q_fill("Der Fernseher ___ gestern den ganzen Tag an. (past)", "war", "Der Fernseher war gestern den ganzen Tag an.", "Past of ist: war."),
  q_choice("You switch it on with anmachen. Then it ___.", ["ist an", "macht an"], "ist an", "Anmachen is the action; an sein is the state.")],
 "Anmachen is the action, an sein is the result: Ich mache das Licht an. Jetzt ist es an.",
 family=[{"german": "aus sein", "english": "to be off; to be over", "type": "phrase"}, {"german": "anmachen", "english": "to turn on", "type": "separable verb"}],
 forms=["ist an", "war an"])

# antworten ----------------------------------------------------------------
card("antworten", "verb", "AHNT-vor-ten", "ˈantvɔʁtn̩", "to answer, to reply",
 [s("Er antwortet nicht.", "He isn't answering.", ["antwortet"]),
  s("Bitte antworten Sie mir bis Freitag.", "Please reply to me by Friday.", ["antworten", "mir"]),
  s("Ich habe auf deine E-Mail geantwortet.", "I replied to your email.", ["auf", "geantwortet."]),
  s("Er gibt leider keine Antwort.", "Unfortunately he isn't giving an answer.", ["Antwort."])],
 [q_choice("Kannst du ___ antworten? (me)", ["mich", "mir"], "mir", "You answer someone in the dative: mir."),
  q_choice("Ich antworte ___ die Frage.", ["auf", "an"], "auf", "Antworten auf + accusative."),
  q_fill("Sie hat nicht ___. (antworten, past)", "geantwortet", "Sie hat nicht geantwortet.", "Ge-antwort-et."),
  q_choice("___ Antwort", ["der", "die", "das"], "die", "Die Antwort, plural die Antworten."),
  q_fill("Er ___ sofort. (antworten, er)", "antwortet", "Er antwortet sofort.", "Stems ending in -t add -et: antwortet.")],
 "Antworten: the person goes in the dative (mir), the question takes auf (auf die Frage).",
 table=present(["antwort|e", "antwort|est", "antwort|et", "antwort|en", "antwort|et", "antwort|en"], perfekt="hat geantwortet",
               note="The stem ends in -t, so du and er add an extra e: du antwortest, er antwortet."),
 tip={"title": "Who and what", "explanation": "The person is dative; the question or message takes auf + accusative.",
      "examples": [{"german": "Ich antworte dir morgen.", "english": "I'll answer you tomorrow.", "highlight": "dir"},
                   {"german": "Ich antworte auf die Frage.", "english": "I answer the question.", "highlight": "auf"}]},
 family=[{"german": "die Antwort", "english": "answer", "type": "noun"}, {"german": "fragen", "english": "to ask", "type": "verb"}],
 forms=["antworte", "antwortest", "antwortet", "geantwortet", "Antwort", "Antworten"])

print("batch 2 done")
