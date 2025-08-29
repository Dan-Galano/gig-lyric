import 'package:flutter/material.dart';
import 'package:giglyric_latest/components/home_empty.dart';
import 'package:giglyric_latest/data/hive_boxes.dart';
import 'package:giglyric_latest/models/lyrics.dart';
import 'package:giglyric_latest/models/setlist.dart';
import 'package:giglyric_latest/screens/lyrics.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    fetchLyrics();
    fetchSetlist();
    // lyricsBox.add(
    //   SongLyrics(id: 1, title: '1', artist: '1', lyrics: '1'),
    // );
    // lyricsBox.add(
    //   SongLyrics(id: 2, title: '2', artist: '2', lyrics: '2'),
    // );
    // lyricsBox.add(
    //   SongLyrics(id: 3, title: '3', artist: '3', lyrics: '3'),
    // );
    // lyricsBox.add(
    //   SongLyrics(id: 4, title: '4', artist: '4', lyrics: '4'),
    // );
    // lyricsBox.add(
    //   SongLyrics(id: 5, title: '5', artist: '5', lyrics: '5'),
    // );
  }

  List<SongLyrics> downloadedSongsList = [];
  List<SongLyrics> filteredSongsList = [];
  List<Setlist> setlist = [];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> fetchLyrics() async {
    downloadedSongsList.clear();
    for (int i = 0; i < lyricsBox.length; i++) {
      SongLyrics songLyrics = lyricsBox.getAt(i) as SongLyrics;
      setState(() {
        downloadedSongsList.add(songLyrics);
        filteredSongsList = List.from(downloadedSongsList);
      });
    }
  }

  Future<void> fetchSetlist() async {
    setlist.clear();
    setState(() {
      for (var item in setlistBox.values) {
        setlist.add(item);
      }
    });
  }

  void filterSongs(String query) {
    setState(() {
      filteredSongsList = downloadedSongsList
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> showConfirmDeleteDialog(int index, SongLyrics song) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete?"),
          content: Text("Are you sure you want to delete (${song.title})?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteSong(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Song (${song.title}) has been deleted."),
                  ),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Color(0xffa6a6a6), fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showOptionBottomSheet(
      BuildContext context, int songId, int index) async {
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
                    showConfirmDeleteDialog(
                        downloadedSongsList.indexOf(filteredSongsList[index]),
                        filteredSongsList[index]);
                  },
                  leading: const Icon(Icons.file_download_off_sharp),
                  title: const Text("Remove from downloads"),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    showAddToSetlistBottomSheet(context, songId, index);
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

  void deleteSong(int index) async {
    //check later if gumagana
    List<Setlist> tempSetlist = List.from(setlist);
    await lyricsBox.deleteAt(index);

    for (int i = 0; i < tempSetlist.length; i++) {
      for (int j = 0; j < tempSetlist[i].songs.length; j++) {
        // print("${setlist[i].name}: ");
        // print(setlist[i].songs[j].title);
        if (downloadedSongsList[index].id == tempSetlist[i].songs[j].id) {
          setState(() {
            setlist[i].songs.removeAt(j);
          });
          await setlistBox.clear();
          for (var item in setlist) {
            await setlistBox.add(item);
          }
          print(true);
        }
      }
    }
    setState(() {
      fetchLyrics();
      fetchSetlist();
    });
    
  }

  Future<void> showAddToSetlistBottomSheet(
      BuildContext context, int songId, int songIndex) async {
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
                                addSongInSetlist(index, songId, songIndex);
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

  Future<void> addSongInSetlist(int index, int songId, int songIndex) async {
    print(
        "SONG ID (ADDED TO ${setlist[index].name}): ${downloadedSongsList[songIndex].title}");
    for (var e in setlist[index].songs) {
      if (e.id == songId) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Song has already been added.")));
        return;
      }
    }

    setState(() {
      setlist[index].songs.add(
            SongLyrics(
              id: songId,
              title: downloadedSongsList[songIndex].title,
              artist: downloadedSongsList[songIndex].artist,
              lyrics: downloadedSongsList[songIndex].lyrics,
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
    print(downloadedSongsList[songIndex].title);
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

  //BACKLOGS:
  //1 Dapat madelete din setlist - DONE
  //2 Searching - DONE
  //3 Remove song from setlist - DONE
  //4 home_screen add to setlist yung song DONE
  //5 setlist if isEmpty, show text saying nothing saved yet

  //change date to desc?

  //BUGS:
  //1 when adding a song in the setlist sa search screen - DONE
  //2 edit setlist - DONE
  //3 after modify -> create, maclclear yung list tapos matitira yung inadd - DONE

  @override
  Widget build(BuildContext context) {
    // print(downloadedSongsList);

    return downloadedSongsList.isNotEmpty
        ? Column(
            children: [
              //search bar
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          filterSongs(value);
                        },
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
                                  onPressed: () {},
                                  icon: const Icon(Icons.search)),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.075),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "All Lyrics",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredSongsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        color: const Color(0xffE8E8E8),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LyricsScreen(
                                songLyrics: filteredSongsList[index],
                              ),
                            ));
                          },
                          title: Text(
                            filteredSongsList[index].title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(downloadedSongsList[index].artist),
                          trailing: IconButton(
                            onPressed: () {
                              showOptionBottomSheet(context,
                                  downloadedSongsList[index].id, index);
                              print(index);
                            },
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : SingleChildScrollView(
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
                                    onPressed: () {},
                                    icon: const Icon(Icons.search)),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(14),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.075),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "All Lyrics",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                const EmptyHomeScreen()
              ],
            ),
          );
  }
}
