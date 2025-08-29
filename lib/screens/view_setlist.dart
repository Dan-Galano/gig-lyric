import 'package:flutter/material.dart';
import 'package:giglyric_latest/data/hive_boxes.dart';
import 'package:giglyric_latest/models/lyrics.dart';
import 'package:giglyric_latest/models/setlist.dart';
import 'package:giglyric_latest/screens/homepage.dart';
import 'package:giglyric_latest/screens/lyrics.dart';
import 'package:gap/gap.dart';

class ViewSetlistScreen extends StatefulWidget {
  ViewSetlistScreen({super.key, required this.setlistIndex});

  final int setlistIndex;

  @override
  State<ViewSetlistScreen> createState() => _ViewSetlistScreenState();
}

class _ViewSetlistScreenState extends State<ViewSetlistScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchSetlist(widget.setlistIndex);
  }

  List<SongLyrics> songs = [];
  late Setlist setlist;

  void fetchSetlist(index) {
    songs.clear();
    setState(() {
      setlist = setlistBox.getAt(index) as Setlist;
      for (var song in setlist.songs) {
        songs.add(song);
      }
    });
  }

  Future<void> showConfirmDeleteDialog(int index, String songName) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove?"),
          content: Text("Remove this song from (${setlist.name})?"),
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
                removeSongFromSetlist(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Song ($songName) has been removed."),
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

  void removeSongFromSetlist(int index) {
    setState(() {
      songs.removeAt(index);
      setlist.songs = songs;
    });
    setlistBox.put(widget.setlistIndex, setlist);
    // fetchSetlist(widget)
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "GigLyric",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SingleChildScrollView(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.075),
              scrollDirection: Axis.horizontal,
              child: Text(
                setlist.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xfff4f4f4),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(newIndex: 2),
                    ));
                  },
                  leading: const Icon(Icons.add),
                  title: const Text(
                    'Add song',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: const Color(0xffE8E8E8),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LyricsScreen(
                              songLyrics: songs[index],
                            ),
                          ));
                        },
                        title: Text(
                          songs[index].title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(songs[index].artist),
                        trailing: IconButton(
                          onPressed: () {
                            showConfirmDeleteDialog(index, songs[index].title);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
