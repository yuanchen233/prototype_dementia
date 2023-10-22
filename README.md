# prototype_dementia
First mini app written in Flutter

##Tech used:
1. Data storage: Firebase Storage
2. Metadata: Firestore Database
3. Frontend with Flutter
4. hosted at http://121.4.248.85/ (cheap server, kinda slow, bear with me thx:dizzy:)

##What the app does:
1. Web application working under Flutter with VScode, a live version is hosted (using file with  > flutter build web)
2. A nevagation bar on the left (via SafeArea) for different category
3. With in each category, pictures are displayed as a list(via ListView, and FutureBuilder to retrive the image)
4. Each picture have a 'like' button, and the number of likes are recorded and saved in the database.
5. Under 'Stats', the number of likes can be viewed (buggy, 2 picture missing with nullpointer)

##What could be done/need to be fixed/notes:
1. Testing and documents (so I can fix the bug)
2. Error handling
3. Some data are hard-coded (e.g. length)
4. Coding style and structure (I'm learn while doing so kinda different approach are used for the same goal)
5. Andriod/IOS application
6. Upload (have problem with unspported platform [windows web], cloud not find a workaround and seems like other ppl have same problems)
7. I did spend a bit more time i think, didn't keep track of it, due to
   Envirnment set up and learn a bit of Flutter and Firebase.
   Can't resolve the image picker bug (no.5), which was not cool
   Front problem, the Icons, when hosting.
8. In general I had a lot of fun, Flutter is pretty stright forward but also some depth, and I like the default UI style.
