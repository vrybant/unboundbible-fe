import 'dart:collection';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'lib.dart';
import 'utils.dart';
import 'extensions.dart';
import 'module.dart';

class Verse {
  int book = 1;
  int chapter = 1;
  int number = 1;
  int count = 1;
}

class Book {
  String title;
  String abbr;
  int number;
  int id;
  int sorting;
  Book(this.title, this.abbr, this.number, this.id, this.sorting);
}

class BibleAlias {
  late String bible, book, chapter, verse, text, books, number, name, abbr;
}

class UnboundAlias extends BibleAlias {
  UnboundAlias() {
    bible = "Bible";
    book = "Book";
    chapter = "Chapter";
    verse = "Verse";
    text = "Scripture";
    books = "Books";
    number = "Number";
    name = "Name";
    abbr = "Abbreviation";
  }
}

class MybibleAlias extends UnboundAlias {
  MybibleAlias() {
    bible = "verses";
    book = "book_number";
    chapter = "chapter";
    verse = "verse";
    text = "text";
    books = "books";
    number = "book_number";
    name = "long_name";
    abbr = "short_name";
  }
}

const titlesArray = [
  "", "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", //
  "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", //
  "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Songs", //
  "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", //
  "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah",
  "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", //
  "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", //
  "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", //
  "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
];

const abbrevArray = [
  "", "Gen.", "Ex.", "Lev.", "Num.", "Deut.", "Josh.", "Judg.", "Ruth", "1 Sam.", "2 Sam.", //
  "1 Kin.", "2 Kin.", "1 Chr.", "2 Chr.", "Ezra", "Neh.", "Esth.", "Job", "Ps.", "Prov.", //
  "Eccl.", "Song", "Is.", "Jer.", "Lam.", "Ezek.", "Dan.", "Hos.", "Joel", "Amos", "Obad.", //
  "Jon.", "Mic.", "Nah.", "Hab.", "Zeph.", "Hag.", "Zech.", "Mal.", "Matt.", "Mark", "Luke", //
  "John", "Acts", "Rom.", "1 Cor.", "2 Cor.", "Gal.", "Eph.", "Phil.", "Col.", "1 Thess.", //
  "2 Thess.", "1 Tim.", "2 Tim.", "Titus", "Philem.", "Heb.", "James", "1 Pet.", "2 Pet.", //
  "1 John", "2 John", "3 John", "Jude", "Rev." //
];

class Bible extends Module {
  List<Book> books = [];
  BibleAlias z = UnboundAlias();

  Bible(String atPath) : super(atPath);

  Future _create() async {
    await opendatabase();
    if (format == FileFormat.mybible) z = MybibleAlias();
//  if (connected & !database.TableExists(z.bible)) connected = false;
    if (connected) await loadDatabase();
  }

  static Future<Bible> create(String atPath) async {
    final bible = Bible(atPath);
    await bible._create();
    return bible;
  }

  Future loadUnboundDatabase() async {
    final query = "SELECT * FROM " + z.books;

    try {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(query);

      List.generate(maps.length, (i) {
        final id = maps[0][z.number] ?? 0;
        final name = maps[0][z.name] ?? "";
        final abbr = maps[0][z.abbr] ?? "";

        if (id > 0) {
          final book = Book(name, abbr, decodeID(id), id, id);
          books.add(book);
          loaded = true;
        }
      });

      connected = true;
    } catch (e) {
      print(e);
    }
    print("loadUnboundDatabase: " + fileName);
  }

  Future loadMyswordDatabase() async {
    final query = "SELECT DISTINCT " + z.book + " FROM " + z.bible;

    try {
      final List<Map<String, dynamic>> maps = await database!.rawQuery(query);

      List.generate(maps.length, (i) {
        final num = maps[0][z.book] ?? 0;

        if ((num > 0) & (num <= 66)) {
          final title = titlesArray[num];
          final abbr = abbrevArray[num];
          final book = Book(title, abbr, num, num, num);
          books.add(book);
          loaded = true;
        }
      });

      connected = true;
    } catch (e) {
      print(e);
    }
    print("loadMyswordDatabase: " + fileName);
  }

  Future loadDatabase() async {
    if (loaded) return;
    if (format == FileFormat.mysword) {
      await loadMyswordDatabase();
    } else {
      await loadUnboundDatabase();
    }
  }

  List<String> getChapter(Verse verse) {
    List<String> result = [];
    int id = encodeID(verse.book);
    bool nt = isNewTestament(verse.book);
    /*
        var query = "select * from " + z.bible + " where " + z.book + " = " + id + " and " + z.chapter + " = " + verse.chapter;

        try {
            var command = database.CreateCommand();
            command.CommandText = query;
            SQLiteDataReader reader = command.ExecuteReader();            

            while (reader.Read()) {
                string line = reader.String(z.text);
                if (line != null) {
                    string text = line; // = preparation(line, format: format, nt: nt, purge: false)
                    result.Add(text);
                }
            }

            if (!result.IsEmpty()) { return result; }
        } catch (SQLiteException ex) {
            Debug.WriteLine(ex.Message);
        }
        */
    return result;
  }
}

extension Bibles on List<Bible> {
  static String? _databasesPath;

  Future _create() async {
    await _load();
  }

  static Future<List<Bible>> create() async {
    List<Bible> bibles = [];
    await bibles._create();
    return bibles;
  }

  Future _load() async {
    _databasesPath = await getDatabasesPath();

    for (var file in databaseList) {
      if (file.contains(".bbl.") | file.hasSuffix(".SQLite3")) {
        final filePath = join(_databasesPath!, file);
        var bible = await Bible.create(filePath);
        if (bible.connected) add(bible);
        print(file + " has been added");
      }
    }
  }
}
