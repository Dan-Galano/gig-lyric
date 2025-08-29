import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giglyric_latest/data/hive_boxes.dart';
import 'package:giglyric_latest/models/lyrics.dart';
import 'package:giglyric_latest/models/setlist.dart';
import 'package:giglyric_latest/models/song.dart';
import 'package:giglyric_latest/screens/lyrics.dart';
import 'package:gap/gap.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchLyric = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLyrics(); //fetch all lyrics to check if user already downloaded the song's lyrics
    fetchSetlist();
    print("SETLIST SIZE: ${setlist.length}");
    // setlistBox.clear();
  }

  List<Setlist> setlist = []; //to add sa setlist

  static List<Song> songList = [
    // Song(songId: 135062, title: "Ignorance", artist: "Paramore"),
  ];

  int prevSongId = 0;
  String songLyricsText = "";
  late SongLyrics song;
  int numberOfResults = 0;

  List<SongLyrics> dlLyrics = [];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, String> headers = {
    'X-RapidAPI-Key': dotenv.env['RAPIDAPI_KEY'] ?? '',
    'X-RapidAPI-Host': dotenv.env['RAPIDAPI_HOST'] ?? '',
  };

  Future<void> fetchSetlist() async {
    setlist.clear();
    setState(() {
      for (var item in setlistBox.values) {
        setlist.add(item);
      }
    });
  }

  Future<void> searchSong(String input) async {
    // print("test");
    songList.clear();
    setState(() {
      numberOfResults = 0; // Reset to 0 before new search
    });
    if (searchLyric.text.isEmpty || searchLyric.text == "") {
      print('no input');
      return;
    }
    //url for searching
    String url =
        'https://genius-song-lyrics1.p.rapidapi.com/search/?q=$input&per_page=10&page=1';

    try {
      // Search song (GET)
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        print("+1 request");
        final jsonData = jsonDecode(response.body);
        List<dynamic> hits = jsonData['hits'];
        print("NUMBER OF ITEMS (HITS): ");
        print(hits.length);
        setState(() {
          numberOfResults = hits.length;

          for (int i = 0; i < hits.length; i++) {
            print(jsonData['hits'][i]['result']['full_title']);
            songList.add(
              Song(
                songId: jsonData['hits'][i]['result']['id'],
                title: jsonData['hits'][i]['result']['full_title'],
                artist: jsonData['hits'][i]['result']['artist_names'],
              ),
            );
          }
          numberOfResults = songList.length;
        });
      } else {
        print(
            'Request to search for songs failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Connection error.")));
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("An error occurred. Please try again later.")));
    }
  }

  Future<void> getLyrics(BuildContext context, int songId) async {
    if (songId == prevSongId) {
      //para di na maulit yung req
      // print(prevSongId);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LyricsScreen(songLyrics: song),
      ));
    } else {
      //url for getting the lyrics
      String lyricsUrl =
          'https://genius-song-lyrics1.p.rapidapi.com/song/lyrics/?id=$songId';
      //Get song lyrics
      final responseLyrics =
          await http.get(Uri.parse(lyricsUrl), headers: headers);

      if (responseLyrics.statusCode == 200) {
        print("+1 request");
        final jsonData = jsonDecode(responseLyrics.body);
        print("LYRICS!!!!");
        setState(() {
          prevSongId = jsonData['lyrics']['tracking_data']['song_id'];

          //convert html to text
          String htmlData = jsonData['lyrics']['lyrics']['body']['html'];
          var document = parse(htmlData.replaceAll('<br>', '\n'));
          songLyricsText = document.body!.text;

          song = SongLyrics(
            id: songId,
            title: jsonData['lyrics']['tracking_data']['title'],
            artist: jsonData['lyrics']['tracking_data']['primary_artist'],
            lyrics: songLyricsText,
          );
        });
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LyricsScreen(songLyrics: song),
        ));
      } else {
        print(
            'Request to get lyrics failed with status: ${responseLyrics.statusCode}');
      }
    }
  }

  Future<void> fetchLyrics() async {
    for (int i = 0; i < lyricsBox.length; i++) {
      SongLyrics songLyrics = lyricsBox.getAt(i) as SongLyrics;
      setState(() {
        dlLyrics.add(songLyrics);
      });
    }
  }

  Future<void> downloadLyrics(int songId) async {
    for (var song in dlLyrics) {
      if (song.id == songId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("This song has already been downloaded.")));
        return;
      }
    }
    String lyricsUrl =
        'https://genius-song-lyrics1.p.rapidapi.com/song/lyrics/?id=$songId';
    //Get song lyrics
    final responseLyrics =
        await http.get(Uri.parse(lyricsUrl), headers: headers);

    if (responseLyrics.statusCode == 200) {
      print("+1 request (download song)");
      final jsonData = jsonDecode(responseLyrics.body);
      var document;
      setState(() {
        //convert html to text
        String htmlData = jsonData['lyrics']['lyrics']['body']['html'];
        document = parse(htmlData.replaceAll('<br>', '\n'));
        lyricsBox.put(
          songId,
          SongLyrics(
            id: songId,
            title: jsonData['lyrics']['tracking_data']['title'],
            artist: jsonData['lyrics']['tracking_data']['primary_artist'],
            lyrics: document.body!.text,
          ),
        );
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lyrics downloaded")));
      print(dlLyrics.length);
    } else {
      print("Request failed with status: ${responseLyrics.statusCode}");
    }
  }

  Future<void> showOptionBottomSheet(BuildContext context, int songId) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    downloadLyrics(songId);
                  },
                  leading: const Icon(Icons.download),
                  title: const Text("Download Song"),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    showAddToSetlistBottomSheet(context, songId);
                  },
                  leading: const Icon(Icons.add),
                  title: const Text("Add to setlist"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addSongInSetlist(int index, int songId) async {
    print("SONG ID (ADD TO SETLIST): $songId");
    for (var e in setlist[index].songs) {
      if (e.id == songId) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Song has already been added.")));
        return;
      }
    }

    String lyricsUrl =
        'https://genius-song-lyrics1.p.rapidapi.com/song/lyrics/?id=$songId';
    //Get song lyrics
    final responseLyrics =
        await http.get(Uri.parse(lyricsUrl), headers: headers);

    if (responseLyrics.statusCode == 200) {
      print("+1 request (download song)");
      final jsonData = jsonDecode(responseLyrics.body);
      var document;

      setState(() {
        //convert html to text
        String htmlData = jsonData['lyrics']['lyrics']['body']['html'];
        document = parse(htmlData.replaceAll('<br>', '\n'));

        setlist[index].songs.insert(
              setlist[index].songs.length,
              SongLyrics(
                id: songId,
                title: jsonData['lyrics']['tracking_data']['title'],
                artist: jsonData['lyrics']['tracking_data']['primary_artist'],
                lyrics: document.body!.text,
              ),
            );
      });
      await setlistBox.clear();
      for (var item in setlist) {
        await setlistBox.add(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved to (${setlist[index].name})"),
        ),
      );
      for (var song in dlLyrics) {
        //check if song is already downloaded
        if (song.id == songId) {
          print('song is already downloaded.');
          return;
        }
      }
      downloadLyrics(songId); //add to downloads na rin
    } else {
      print("Request failed with status: ${responseLyrics.statusCode}");
    }
  }

  Future<void> showAddToSetlistBottomSheet(
      BuildContext context, int songId) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Add to Setlist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                setlist.isEmpty
                    ? const Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Your setlist is empty.',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: setlist.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                addSongInSetlist(index, songId);
                                Navigator.of(context).pop();
                              },
                              title: Text(setlist[index].name),
                              subtitle: Text(setlist[index].date),
                            );
                          },
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton.extended(
                    backgroundColor: const Color(0xff2B2B2B),
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showNewSetlistDialog(context);
                    },
                    label: const Text("New Setlist"),
                    icon: const Icon(Icons.add),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showNewSetlistDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameCon = TextEditingController();
        final TextEditingController dateCon = TextEditingController();
        return AlertDialog(
          title: const Text(
            'New setlist',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Required field.";
                    }
                    return null;
                  },
                  controller: nameCon,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                  ),
                ),
                TextField(
                  controller: dateCon,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameCon.clear();
                dateCon.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xffa6a6a6), fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String date;
                  if (dateCon.text.isEmpty || dateCon.text == "") {
                    date = "Unknown";
                  } else {
                    date = dateCon.text;
                  }
                  await setlistBox.add(
                    Setlist(
                      id: setlist.length,
                      name: nameCon.text,
                      date: date,
                      songs: [],
                    ),
                  );
                  setState(() {
                    fetchSetlist();
                  });
                  print("SETLIST SIZE AFTER CREATE: ${setlist.length}");
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Setlist (${nameCon.text}) has been created.")));
                  fetchSetlist();
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

//bakbakan na
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          //serach bar
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    onSubmitted: (value) {
                      searchSong(value);
                    },
                    controller: searchLyric,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        label: const Text("Search"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                              onPressed: () {
                                searchSong(searchLyric.text);
                              },
                              icon: const Icon(Icons.search)),
                        )),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: ListView.builder(
              itemCount: numberOfResults,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: const Color(0xffE8E8E8),
                    child: ListTile(
                      onTap: () => getLyrics(context, songList[index].songId),
                      title: Text(
                        songList[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(songList[index].artist),
                      trailing: IconButton(
                        onPressed: () {
                          showOptionBottomSheet(
                              context, songList[index].songId);
                        },
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
