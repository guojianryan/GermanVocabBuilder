from lib import *

# ab -----------------------------------------------------------------------
full({
 "word": {"headword": "ab", "partOfSpeech": "preposition and separable prefix",
  "pronunciation": {"respelling": "AHP", "ipa": "ap", "notes": "The b sounds like p at the end of a word."},
  "meaning": "from (a point in time or place); off, away",
  "shortDefinition": "Marks a starting point, or something moving away."},
 "intro": {"title": "From now on", "paragraphs": [
  "Ab is a tiny word with two jobs. On its own it marks a starting point: ab Montag, from Monday. As a prefix it means 'off' or 'away', and it's inside dozens of A1 verbs: abfahren, abholen, abgeben."]},
 "etymology": {"title": "Where it comes from",
  "summary": "Ab is the German cousin of English 'off' and 'of'. Both once meant 'away from'.",
  "cognates": [{"word": "off", "language": "English"}, {"word": "of", "language": "English"}, {"word": "af", "language": "Dutch"}]},
 "wordFamily": [
  {"german": "abfahren", "english": "to depart", "type": "separable verb"},
  {"german": "abholen", "english": "to pick up", "type": "separable verb"},
  {"german": "ab und zu", "english": "now and then", "type": "phrase"},
  {"german": "seit", "english": "since (until now)", "type": "preposition"}],
 "keyTrap": {"title": "The big trap: ab or seit?",
  "explanation": "Ab looks forward from a starting point. Seit looks back at something that started in the past and is still going on.",
  "wrong": {"german": "Ich wohne ab 2020 in Berlin.", "verdict": "You've lived there since 2020, so it's seit."},
  "correct": [
   {"german": "Ich wohne seit 2020 in Berlin.", "literal": "I live since 2020 in Berlin.", "note": "Started in the past, still true: seit."},
   {"german": "Ab Montag arbeite ich in Berlin.", "literal": "From Monday I work in Berlin.", "note": "Starting from a point: ab."}]},
 "commonMistakes": [
  {"title": "As a verb prefix it splits", "explanation": "Ab- verbs are separable, so ab goes to the end of the sentence.",
   "wrong": "Der Zug abfährt um acht.", "correct": "Der Zug fährt um acht ab."},
  {"title": "Prices and ages", "explanation": "Ab also means 'from … up' for prices and ages.",
   "examples": [{"german": "Zimmer ab 50 Euro", "english": "rooms from 50 euros", "highlight": "ab"},
                {"german": "ab 18 Jahren", "english": "for ages 18 and up", "highlight": "ab"}]}],
 "sampleSentences": [
  s("Ab morgen habe ich Urlaub.", "From tomorrow I'm on holiday.", ["Ab"]),
  s("Der Bus fährt um 7 Uhr ab.", "The bus leaves at 7.", ["fährt", "ab."]),
  s("Ab und zu gehe ich ins Kino.", "I go to the cinema now and then.", ["Ab"]),
  s("Ab hier müssen Sie zu Fuß gehen.", "From here you have to walk.", ["Ab"])],
 "forms": ["ab und zu"],
 "memoryHook": "Ab = off, away, from here on. Ab Montag looks forward; seit Montag looks back.",
 "signOff": "Ab jetzt weißt du es!"},
 [q_choice("Ich lerne ___ drei Monaten Deutsch.", ["ab", "seit"], "seit", "Started in the past and still going: seit."),
  q_choice("___ nächster Woche habe ich einen neuen Job.", ["Ab", "Seit"], "Ab", "Starting from a future point: ab."),
  q_fill("Der Zug fährt um 9 Uhr ___.", "ab", "Der Zug fährt um 9 Uhr ab.", "Abfahren splits; ab goes to the end."),
  q_fill("___ und zu trinke ich Kaffee. (now and then)", "Ab", "Ab und zu trinke ich Kaffee.", "Ab und zu: now and then."),
  q_choice("What does 'Tickets ab 10 Euro' mean?", ["tickets up to 10 euros", "tickets from 10 euros"], "tickets from 10 euros", "Ab = starting from.")])

# aber ---------------------------------------------------------------------
full({
 "word": {"headword": "aber", "partOfSpeech": "conjunction; also a particle",
  "pronunciation": {"respelling": "AH-ber", "ipa": "ˈaːbɐ", "notes": "Long a. The -er at the end sounds like a soft 'uh'."},
  "meaning": "but; (as a particle) really",
  "shortDefinition": "Joins two ideas that contrast."},
 "intro": {"title": "But…", "paragraphs": [
  "Aber is your everyday 'but': Ich bin müde, aber glücklich. It also has a second life as a small emotional word: Das ist aber schön! means 'That's really nice!'"]},
 "wordFamily": [
  {"german": "sondern", "english": "but rather (after a negative)", "type": "conjunction"},
  {"german": "doch", "english": "but still; yes (contradicting)", "type": "particle"},
  {"german": "trotzdem", "english": "nevertheless", "type": "adverb"}],
 "keyTrap": {"title": "The big trap: aber or sondern?",
  "explanation": "After nicht or kein, when you replace one thing with another, German uses sondern, not aber.",
  "wrong": {"german": "Das ist nicht rot, aber blau.", "verdict": "You're correcting rot to blau, so it's sondern."},
  "correct": [
   {"german": "Das ist nicht rot, sondern blau.", "literal": "That's not red but rather blue.", "note": "Correction after nicht: sondern."},
   {"german": "Das Auto ist alt, aber gut.", "literal": "The car is old but good.", "note": "A contrast: aber."}]},
 "commonMistakes": [
  {"title": "Word order stays normal", "explanation": "Aber doesn't count as a sentence position, so the subject and verb come straight after it in their usual order.",
   "wrong": "Ich bin müde, aber muss ich arbeiten.", "correct": "Ich bin müde, aber ich muss arbeiten."},
  {"title": "aber as a feeling word", "explanation": "Inside a sentence, aber adds surprise or emphasis.",
   "examples": [{"german": "Du bist aber groß geworden!", "english": "My, you've grown!", "highlight": "aber"}]}],
 "sampleSentences": [
  s("Die Wohnung ist schön, aber teuer.", "The flat is nice, but expensive.", ["aber"]),
  s("Ich möchte kommen, aber ich habe keine Zeit.", "I'd like to come, but I don't have time.", ["aber"]),
  s("Das ist aber nett von Ihnen!", "That's really kind of you!", ["aber"]),
  s("Er spricht nicht Englisch, sondern Deutsch.", "He doesn't speak English, but German.", ["sondern"])],
 "forms": [],
 "memoryHook": "Aber = but. If you're correcting a nicht, switch to sondern.",
 "signOff": "Aber gern!"},
 [q_choice("Ich habe Hunger, ___ kein Geld.", ["aber", "sondern"], "aber", "A contrast: aber."),
  q_choice("Das ist kein Tee, ___ Kaffee.", ["aber", "sondern"], "sondern", "Correcting after kein: sondern."),
  q_choice("Which sentence is correct?", ["Es regnet, aber wir gehen spazieren.", "Es regnet, aber gehen wir spazieren."], "Es regnet, aber wir gehen spazieren.", "Aber doesn't change the word order."),
  q_fill("Das Essen ist gut, ___ zu salzig. (but)", "aber", "Das Essen ist gut, aber zu salzig.", "Aber joins the contrast."),
  q_choice("What does 'Das ist aber schön!' mean?", ["That's really nice!", "But that's nice."], "That's really nice!", "Here aber adds emphasis.")])

# abfahren -----------------------------------------------------------------
card("abfahren", "separable verb", "AHP-fah-ren", "ˈapfaːʁən", "to depart, to leave (by vehicle)",
 [s("Wann fährt der Zug ab?", "When does the train leave?", ["fährt", "ab?"]),
  s("Wir fahren morgen früh ab.", "We're leaving early tomorrow morning.", ["fahren", "ab."]),
  s("Der Bus ist schon abgefahren.", "The bus has already left.", ["abgefahren."]),
  s("Die Abfahrt ist um 10:15 Uhr.", "Departure is at 10:15.", ["Abfahrt"])],
 [q_fill("Der Zug ___ um acht Uhr ab.", "fährt", "Der Zug fährt um acht Uhr ab.", "Fahren changes to fährt for er, sie, es.", accept=["faehrt"]),
  q_choice("Der Bus ___ schon abgefahren.", ["hat", "ist"], "ist", "Verbs of movement use sein in the Perfekt."),
  q_fill("Die ___ ist um 9 Uhr. (departure)", "Abfahrt", "Die Abfahrt ist um 9 Uhr.", "The noun is die Abfahrt."),
  q_choice("Which sentence is correct?", ["Wir abfahren um zehn.", "Wir fahren um zehn ab."], "Wir fahren um zehn ab.", "Ab goes to the end."),
  q_choice("On a departure board, Abfahrt means…", ["arrival", "departure"], "departure", "Ankunft is arrival.")],
 "Ab = away, fahren = to travel. You fahr away: abfahren. On the board, Abfahrt sits next to Ankunft.",
 table=present(["fahre … |ab", "fährst … |ab", "fährt … |ab", "fahren … |ab", "fahrt … |ab", "fahren … |ab"],
               perfekt="ist abgefahren", note="Fahren adds an umlaut for du and er: du fährst, er fährt."),
 family=[{"german": "die Abfahrt", "english": "departure", "type": "noun"},
         {"german": "die Ankunft", "english": "arrival", "type": "noun"},
         {"german": "fahren", "english": "to drive, to go (by vehicle)", "type": "verb"}],
 forms=["fahre ab", "fährst ab", "fährt ab", "abgefahren", "fuhr ab", "Abfahrt"], sign="Gute Fahrt!")

# abgeben ------------------------------------------------------------------
card("abgeben", "separable verb", "AHP-gay-ben", "ˈapɡeːbn̩", "to hand in, to hand over",
 [s("Bitte geben Sie den Test jetzt ab.", "Please hand in the test now.", ["geben", "ab."]),
  s("Ich muss den Schlüssel an der Rezeption abgeben.", "I have to hand in the key at reception.", ["abgeben."]),
  s("Hast du das Formular schon abgegeben?", "Have you handed in the form yet?", ["abgegeben?"])],
 [q_fill("Ich ___ den Schlüssel morgen ab.", "gebe", "Ich gebe den Schlüssel morgen ab.", "Geben in second place, ab at the end."),
  q_fill("Er ___ seine Hausaufgaben ab.", "gibt", "Er gibt seine Hausaufgaben ab.", "Geben changes to gibt for er, sie, es."),
  q_fill("Ich habe den Brief schon ___.", "abgegeben", "Ich habe den Brief schon abgegeben.", "Ge goes in the middle: ab-ge-geben."),
  q_choice("You return your hotel key. You ___ it.", ["abholen", "abgeben"], "abgeben", "Abholen means to pick up."),
  q_choice("Which sentence is correct?", ["Du abgibst den Test.", "Du gibst den Test ab."], "Du gibst den Test ab.", "Ab goes to the end.")],
 "Geben = give, ab = away. You give it away from you: abgeben.",
 table=present(["gebe … |ab", "gibst … |ab", "gibt … |ab", "geben … |ab", "gebt … |ab", "geben … |ab"],
               perfekt="hat abgegeben", note="Geben changes e to i for du and er: du gibst, er gibt."),
 forms=["gebe ab", "gibst ab", "gibt ab", "abgegeben", "gab ab"])

# abholen ------------------------------------------------------------------
card("abholen", "separable verb", "AHP-hoh-len", "ˈaphoːlən", "to pick up, to collect",
 [s("Ich hole dich um sechs am Bahnhof ab.", "I'll pick you up at the station at six.", ["hole", "ab."]),
  s("Wann kann ich meine Brille abholen?", "When can I collect my glasses?", ["abholen?"]),
  s("Meine Mutter hat die Kinder abgeholt.", "My mother picked up the children.", ["abgeholt."])],
 [q_fill("Ich ___ dich vom Flughafen ab.", "hole", "Ich hole dich vom Flughafen ab.", "Holen in second place, ab at the end."),
  q_fill("Wir haben das Paket ___.", "abgeholt", "Wir haben das Paket abgeholt.", "Ab-ge-holt."),
  q_choice("Kannst du mich ___ abholen?", ["vom Bahnhof", "zum Bahnhof"], "vom Bahnhof", "You pick someone up from a place: von + dem = vom."),
  q_choice("You collect your parcel from the post office. You ___ it.", ["abholen", "abgeben"], "abholen", "Abholen: collect. Abgeben: hand in."),
  q_choice("Which sentence is correct?", ["Er holt seine Tochter ab.", "Er abholt seine Tochter."], "Er holt seine Tochter ab.", "Ab goes to the end.")],
 "Holen = fetch. Ab-holen = go and fetch it from somewhere.",
 tip={"title": "abholen or abgeben?", "explanation": "They're opposites: abholen is to collect, abgeben is to hand in.",
      "examples": [{"german": "Ich hole das Paket ab.", "english": "I collect the parcel.", "highlight": "ab."},
                   {"german": "Ich gebe das Paket ab.", "english": "I hand in the parcel.", "highlight": "ab."}]},
 family=[{"german": "holen", "english": "to fetch", "type": "verb"}],
 forms=["hole ab", "holst ab", "holt ab", "abgeholt"])

# Absender -----------------------------------------------------------------
noun("Absender", "m", "Absender", "AHP-zen-der", "ˈapzɛndɐ", "sender (on a letter or parcel)",
 [s("Auf dem Brief steht kein Absender.", "There's no sender on the letter.", ["Absender."]),
  s("Bitte schreiben Sie den Absender oben links.", "Please write the sender's address at the top left.", ["Absender"]),
  s("Das Paket geht zurück an den Absender.", "The parcel is going back to the sender.", ["Absender."])],
 [q_choice("The person who receives a letter is the…", ["Absender", "Empfänger"], "Empfänger", "Absender sends, Empfänger receives."),
  q_fill("Das Paket geht zurück an den ___.", "Absender", "Das Paket geht zurück an den Absender.", "Back to the sender."),
  q_choice("Absender is built from ab + senden. Senden means…", ["to send", "to read", "to write"], "to send", "Ab-sender: the one who sends it away.")],
 "Ab + senden = the one who sends it away. Its partner is der Empfänger, the receiver.",
 note="The plural looks the same.",
 family=[{"german": "senden", "english": "to send", "type": "verb"}, {"german": "der Empfänger", "english": "recipient", "type": "noun"}],
 forms=["Absenders"])

# Achtung ------------------------------------------------------------------
card("Achtung", "interjection; noun, feminine (die Achtung)", "AHKH-toong", "ˈaxtʊŋ", "attention! watch out!",
 [s("Achtung! Der Boden ist nass.", "Caution! The floor is wet.", ["Achtung!"]),
  s("Achtung an Gleis 3: Der Zug fährt ein.", "Attention at platform 3: the train is arriving.", ["Achtung"]),
  s("Vorsicht, die Treppe!", "Watch out, the stairs!", ["Vorsicht,"])],
 [q_choice("You hear 'Achtung!' at a station. It means…", ["Attention!", "Thank you!", "Goodbye!"], "Attention!", "Achtung calls for attention."),
  q_choice("___ Achtung", ["der", "die", "das"], "die", "-ung nouns are feminine."),
  q_choice("Which word also means 'watch out'?", ["Vorsicht", "Ausgang", "Eingang"], "Vorsicht", "Vorsicht! is also a warning."),
  q_fill("___! Das Wasser ist heiß. (Careful!)", "Vorsicht", "Vorsicht! Das Wasser ist heiß.", "Vorsicht or Achtung both work.", accept=["Achtung"]),
  q_choice("The ch in Achtung sounds like…", ["the ch in 'church'", "the ch in Scottish 'loch'"], "the ch in Scottish 'loch'", "After a, o and u, ch is the throaty sound.")],
 "Achtung is what the station speaker says before every announcement. Hear it and look up.",
 note="After a, ch is the throaty sound in Scottish 'loch'.",
 tip={"title": "Achtung or Vorsicht?", "explanation": "Both warn. Achtung also introduces announcements; Vorsicht is more about physical danger.",
      "examples": [{"german": "Vorsicht, Stufe!", "english": "Mind the step!", "highlight": "Vorsicht,"}]},
 family=[{"german": "die Vorsicht", "english": "caution", "type": "noun"}], sign="Achtung, fertig, los!")

# Adresse ------------------------------------------------------------------
noun("Adresse", "f", "Adressen", "ah-DRESS-uh", "aˈdʁɛsə", "address",
 [s("Wie ist Ihre Adresse?", "What's your address?", ["Adresse?"]),
  s("Meine neue Adresse ist Lindenstraße 12.", "My new address is Lindenstraße 12.", ["Adresse"]),
  s("Schick mir bitte deine E-Mail-Adresse.", "Please send me your email address.", ["E-Mail-Adresse."])],
 [q_choice("Where's the stress in Adresse?", ["A-dresse", "a-DRES-se"], "a-DRES-se", "Unlike English, the stress is on the second syllable."),
  q_fill("Wie ist Ihre ___? (address)", "Adresse", "Wie ist Ihre Adresse?", "Adresse with double s and an e at the end."),
  q_choice("Which spelling is correct?", ["Adress", "Adresse", "Addresse"], "Adresse", "One d, two s, and an e at the end.")],
 "Adresse is English 'address' with one d and a German e on the end. Stress the middle: a-DRES-se.",
 note="Stress the second syllable.", tip={"title": "Spelling", "explanation": "One d, two s, final e.", "wrong": "Addresse", "correct": "Adresse"})

# all- ---------------------------------------------------------------------
full({
 "word": {"headword": "all-", "partOfSpeech": "determiner and pronoun (alle, alles)",
  "pronunciation": {"respelling": "AHL-uh, AHL-es", "ipa": "ˈalə, ˈaləs", "notes": "Short a, double l."},
  "meaning": "all; alle = everyone, alles = everything",
  "shortDefinition": "The whole of something, or every one of a group."},
 "intro": {"title": "Alles klar?", "paragraphs": [
  "You'll hear alles klar a dozen times a day: everything clear, all good. The word is all-, and its ending tells you what it refers to: alle for people or plural things, alles for 'everything'."]},
 "etymology": {"title": "Where it comes from",
  "summary": "All- is the same word as English 'all'. It also hides in allein: all + ein, 'all one'.",
  "cognates": [{"word": "all", "language": "English"}, {"word": "al, alle", "language": "Dutch"}]},
 "tables": [{"title": "Which ending?", "columns": ["form", "meaning", "example"],
  "rows": [
   {"label": "alle", "cells": ["all|e", "all, everyone (plural)", "Alle sind da."]},
   {"label": "alles", "cells": ["all|es", "everything", "Alles ist gut."]},
   {"label": "allen", "cells": ["all|en", "to/with all (dative)", "mit allen Freunden"]}]}],
 "wordFamily": [
  {"german": "Alles klar!", "english": "All right! Got it!", "type": "phrase"},
  {"german": "Alles Gute!", "english": "All the best!", "type": "phrase"},
  {"german": "allein", "english": "alone", "literal": "all one", "type": "adjective"},
  {"german": "jeder", "english": "each, every (singular)", "type": "determiner"}],
 "keyTrap": {"title": "The big trap: alle or alles?",
  "explanation": "Alle points at a group of people or things. Alles means 'everything' and takes a singular verb.",
  "wrong": {"german": "Alle ist gut.", "verdict": "'Everything is good' needs alles."},
  "correct": [
   {"german": "Alles ist gut.", "literal": "Everything is good.", "note": "Everything: alles, singular verb."},
   {"german": "Alle sind gut.", "literal": "All are good.", "note": "Everyone or all of them: alle, plural verb."}]},
 "commonMistakes": [
  {"title": "Every day", "explanation": "For 'every' with a singular noun, use jeder. Alle needs a plural.",
   "wrong": "alle Tag", "correct": "jeden Tag / alle Tage"},
  {"title": "Useful phrases", "explanation": "These come up constantly.",
   "examples": [{"german": "Alles Gute zum Geburtstag!", "english": "Happy birthday!", "highlight": "Alles"},
                {"german": "Das ist alles.", "english": "That's all.", "highlight": "alles."}]}],
 "sampleSentences": [
  s("Sind alle da?", "Is everyone here?", ["alle"]),
  s("Ich habe alles verstanden.", "I understood everything.", ["alles"]),
  s("Alle Kinder spielen im Garten.", "All the children are playing in the garden.", ["Alle"]),
  s("Alles klar, bis morgen!", "All right, see you tomorrow!", ["Alles"])],
 "forms": ["alle", "alles", "allen", "aller"],
 "memoryHook": "Alle = all of them, plural. Alles = everything, singular. Alles klar?",
 "signOff": "Alles Gute!"},
 [q_choice("___ ist teuer hier. (Everything)", ["Alle", "Alles"], "Alles", "Everything: alles."),
  q_choice("___ Freunde kommen zur Party.", ["Alle", "Alles"], "Alle", "A plural group: alle."),
  q_fill("___ Gute zum Geburtstag!", "Alles", "Alles Gute zum Geburtstag!", "Alles Gute: all the best."),
  q_choice("Ich gehe ___ Tag joggen. (every)", ["alle", "jeden"], "jeden", "Every + singular noun: jeden."),
  q_choice("Someone asks 'Alles klar?'. It means…", ["Is everything clear / OK?", "Is everyone here?"], "Is everything clear / OK?", "Alles = everything.")])

# allein -------------------------------------------------------------------
card("allein", "adjective / adverb", "ah-LINE", "aˈlaɪn", "alone; on your own",
 [s("Ich wohne allein.", "I live alone.", ["allein."]),
  s("Kannst du das allein machen?", "Can you do that on your own?", ["allein"]),
  s("Das Kind ist noch zu klein, um allein zu Hause zu bleiben.", "The child is still too young to stay home alone.", ["allein"])],
 [q_choice("Allein means…", ["together", "alone", "everyone"], "alone", "All + ein: all one, alone."),
  q_choice("Where's the stress?", ["AL-lein", "al-LEIN"], "al-LEIN", "Stress the second syllable."),
  q_fill("Er fährt ___ in den Urlaub. (alone)", "allein", "Er fährt allein in den Urlaub.", "Allein: alone."),
  q_choice("The opposite of allein is…", ["zusammen", "alles"], "zusammen", "Zusammen: together."),
  q_choice("Allein is built from…", ["all + ein", "alle + in"], "all + ein", "Like English 'alone' from 'all one'.")],
 "Allein = all + ein, 'all one', exactly like English 'alone' = 'all one'.",
 ety={"summary": "All + ein: 'all one'. English 'alone' was built the same way.",
      "cognates": [{"word": "alone", "language": "English", "note": "from 'all one'"}, {"word": "alleen", "language": "Dutch"}]},
 family=[{"german": "zusammen", "english": "together", "type": "adverb"}])

# also ---------------------------------------------------------------------
full({
 "word": {"headword": "also", "partOfSpeech": "adverb / particle",
  "pronunciation": {"respelling": "AHL-zoh", "ipa": "ˈalzo", "notes": "The s sounds like z."},
  "meaning": "so, therefore; well…",
  "shortDefinition": "Draws a conclusion or starts a thought."},
 "intro": {"title": "Also doesn't mean 'also'", "paragraphs": [
  "Also looks exactly like the English word, but it means 'so' or 'therefore'. Germans also use it the way English speakers say 'so…' or 'well…' to start a sentence. For 'also', German says auch."]},
 "wordFamily": [
  {"german": "auch", "english": "also, too", "type": "adverb"},
  {"german": "deshalb", "english": "that's why", "type": "adverb"},
  {"german": "Also gut!", "english": "All right then!", "type": "phrase"}],
 "keyTrap": {"title": "The big trap: also is 'so'",
  "explanation": "When you mean 'too' or 'as well', you need auch.",
  "wrong": {"german": "Ich spreche also Englisch.", "verdict": "This means 'So I speak English.'"},
  "correct": [
   {"german": "Ich spreche auch Englisch.", "literal": "I speak also English.", "note": "Too, as well: auch."},
   {"german": "Es regnet, also bleiben wir zu Hause.", "literal": "It's raining, so we stay at home.", "note": "Therefore: also."}]},
 "commonMistakes": [
  {"title": "Word order after also", "explanation": "When also starts the clause, the verb comes right after it.",
   "wrong": "Es ist spät, also ich gehe.", "correct": "Es ist spät, also gehe ich."},
  {"title": "Starting a sentence", "explanation": "Also, … works like English 'So, …' or 'Well, …'.",
   "examples": [{"german": "Also, wo waren wir?", "english": "So, where were we?", "highlight": "Also,"}]}],
 "sampleSentences": [
  s("Er hat keine Zeit, also kommt er nicht.", "He has no time, so he isn't coming.", ["also"]),
  s("Also, was möchtest du trinken?", "So, what would you like to drink?", ["Also,"]),
  s("Ich komme auch mit.", "I'm coming too.", ["auch"]),
  s("Also gut, machen wir das so.", "All right then, let's do it that way.", ["Also"])],
 "forms": [],
 "memoryHook": "Also = so. Auch = also. Swap them in your head.",
 "signOff": "Also, bis bald!"},
 [q_choice("Ich trinke Tee, und meine Frau trinkt ___ Tee. (too)", ["also", "auch"], "auch", "Too, as well: auch."),
  q_choice("Der Laden ist zu, ___ gehen wir nach Hause. (so)", ["also", "auch"], "also", "Therefore: also."),
  q_choice("Which sentence is correct?", ["Es ist spät, also ich gehe.", "Es ist spät, also gehe ich."], "Es ist spät, also gehe ich.", "The verb comes right after also."),
  q_choice("German 'also' means…", ["also, too", "so, therefore"], "so, therefore", "A false friend."),
  q_fill("Ich bin ___ Lehrerin. (I'm a teacher too.)", "auch", "Ich bin auch Lehrerin.", "Too: auch.")])

# alt ----------------------------------------------------------------------
card("alt", "adjective", "AHLT", "alt", "old",
 [s("Wie alt bist du? – Ich bin 25 Jahre alt.", "How old are you? – I'm 25.", ["alt", "alt."]),
  s("Mein Bruder ist älter als ich.", "My brother is older than me.", ["älter"]),
  s("Wir wohnen in einem alten Haus.", "We live in an old house.", ["alten"]),
  s("Das Alter spielt keine Rolle.", "Age doesn't matter.", ["Alter"])],
 [q_fill("Wie ___ sind Sie?", "alt", "Wie alt sind Sie?", "Asking someone's age."),
  q_fill("Meine Schwester ist ___ als ich. (older)", "älter", "Meine Schwester ist älter als ich.", "Alt, älter, am ältesten.", accept=["aelter"]),
  q_choice("Ich bin 30 ___ alt.", ["Jahr", "Jahre"], "Jahre", "Ages use the plural: 30 Jahre alt."),
  q_choice("The opposite of alt (for people) is…", ["jung", "neu"], "jung", "For people: jung. For things: neu."),
  q_choice("das ___ (age)", ["Alt", "Alter", "Alte"], "Alter", "The noun is das Alter.")],
 "Alt = old, like English 'old' and 'elder'. Älter has the umlaut, just as 'elder' changes its vowel.",
 table={"title": "Old, older, oldest", "columns": ["form"], "rows": [
   {"label": "old", "cells": ["alt"]}, {"label": "older", "cells": ["|älter"]}, {"label": "oldest", "cells": ["am |ältesten"]}],
   "notes": ["The umlaut appears in the comparative: älter, not alter."]},
 tip={"title": "Opposites", "explanation": "For people the opposite is jung; for things it's neu.",
      "examples": [{"german": "ein junger Mann", "english": "a young man", "highlight": "junger"},
                   {"german": "ein neues Auto", "english": "a new car", "highlight": "neues"}]},
 family=[{"german": "das Alter", "english": "age", "type": "noun"}, {"german": "jung", "english": "young", "type": "adjective"},
         {"german": "neu", "english": "new", "type": "adjective"}],
 forms=["alte", "alten", "alter", "altes", "älter", "ältesten", "Alter"])

print("batch 1 done")
