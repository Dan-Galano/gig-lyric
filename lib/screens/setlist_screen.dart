import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giglyric_latest/components/setlist_empty.dart';
import 'package:giglyric_latest/data/hive_boxes.dart';
import 'package:giglyric_latest/models/setlist.dart';
import 'package:giglyric_latest/screens/view_setlist.dart';
import 'package:gap/gap.dart';

class SetlistScreen extends StatefulWidget {
  const SetlistScreen({super.key});

  @override
  State<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends State<SetlistScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Setlist> setlist = [];
  List<Setlist> filteredSetlist = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    // setlistBox.clear();
  }

  void filterSetlist(String query) {
    setState(() {
      filteredSetlist = setlist
          .where((setlist) =>
              setlist.name.toLowerCase().contains(query.toLowerCase()) ||
              setlist.date.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void fetchData() {
    setlist.clear();
    for (int i = 0; i < setlistBox.length; i++) {
      Setlist item = setlistBox.getAt(i) as Setlist;
      setState(() {
        setlist.add(item);
        filteredSetlist = List.from(setlist);
      });
    }
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String date;
                  if (dateCon.text.isEmpty || dateCon.text == "") {
                    date = "Unknown";
                  } else {
                    date = dateCon.text;
                  }
                  setlistBox.add(
                    Setlist(
                      id: setlist.length,
                      name: nameCon.text,
                      date: date,
                      songs: [],
                    ),
                  );
                  setState(() {
                    setlist.clear();
                    fetchData();
                  });
                  print(setlist.length);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Setlist (${nameCon.text}) has been created.")));
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

  void viewSetlist(BuildContext context, int index) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => ViewSetlistScreen(
        setlistIndex: index,
      ),
    ));
  }

  Future<void> showConfirmDeleteDialog(int index, String setlistName) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete?"),
          content: const Text("Are you sure you want to delete this?"),
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
                setState(() {
                  deleteSetlist(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Setlist ($setlistName) has been deleted."),
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

  void deleteSetlist(int index) {
    setlistBox.deleteAt(index);
    setState(() {
      setlist.clear();
      fetchData();
    });
    print("NEW SETLIST SIZE: ${setlist.length}");
  }

  Future<void> showEditSetlistDialog(BuildContext context, int index) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameCon = TextEditingController();
        final TextEditingController dateCon = TextEditingController();

        nameCon.text = setlist[index].name;
        if (setlist[index].date != "Unknown") {
          dateCon.text = setlist[index].date;
        }

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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String date;
                  if (dateCon.text.isEmpty || dateCon.text == "") {
                    date = "Unknown";
                  } else {
                    date = dateCon.text;
                  }
                  setState(() {
                    editSetlist(index, nameCon.text, date);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> editSetlist(int index, String name, String date) async {
    setState(() {
      setlist[index].name = name;
      setlist[index].date = date;
    });
    await setlistBox.clear();
    for (var item in setlist) {
      await setlistBox.add(item);
    }
    fetchData();
  }

  Future<void> showOptionBottomSheet(BuildContext context, int index) async {
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
                    showEditSetlistDialog(context, index);
                  },
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text("Edit setlist"),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    // showAddToSetlistBottomSheet(context, songId);
                    showConfirmDeleteDialog(index, setlist[index].name);
                  },
                  leading: const Icon(Icons.delete_outline),
                  title: const Text("Delete setlist"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return setlist.isNotEmpty
        ? Column(
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
                        onChanged: (value) {
                          filterSetlist(value);
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
                      "All Setlist",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: const Color(0xfff4f4f4),
                  child: ListTile(
                    onTap: () async => showNewSetlistDialog(context),
                    leading: const Icon(Icons.add),
                    title: const Text(
                      'New setlist',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSetlist.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        color: const Color(0xffE8E8E8),
                        child: ListTile(
                          onTap: () {
                            viewSetlist(context, index);
                          },
                          title: Text(
                            filteredSetlist[index].name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(filteredSetlist[index].date),
                          trailing: IconButton(
                            onPressed: () {
                              // showConfirmDeleteDialog(
                              //     index, filteredSetlist[index].name);
                              showOptionBottomSheet(context, index);
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
                        "Setlist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Column(
                  children: [
                    const EmptySetlistScreen(),
                    SizedBox(
                      width: 255,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async => showNewSetlistDialog(context),
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Color(0xff2B2B2B)),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white),
                        ),
                        child: const Text(
                          "Create Setlist",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
