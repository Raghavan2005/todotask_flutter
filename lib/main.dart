import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{

  runApp(

     MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Myapp(),
      theme: ThemeData(
      fontFamily: "PoetsenOne"
      ),
    )
  );

}



enum TaskStatus{
  Complete,
Incomplete,
pending
}

//home
class Myapp extends StatefulWidget {
  const Myapp({super.key});
  @override
  State<Myapp> createState() => _MyappState();

}

class _MyappState extends State<Myapp> {
  final myController = TextEditingController();
  List<String> TodoList=[];
  List<bool> TodoListCheck=[];
  String? AddTask = ' ';

  // Obtain shared preferences.
 @override
  void initState  ()  {
   Future.delayed(Duration.zero,() async {
     List<String> temp = await getAsTask();
     List<bool> bolltemo = await getAsBool();
     setState(() {
       TodoList=temp;
       TodoListCheck=bolltemo;
     });
   });
   super.initState();
 }


  //Todo : save the task in string list//
  //Todo : save the sataus in string list//
  //todo : retrive the data and save as list
  //todo : check for old data and paste it


  saveAsList(List<String> input)async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList("task", input);
  }
   saveAsBool(List<bool> input)async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
   String chnagestring = input.join(',');
   List<String> chnagedtolist = chnagestring.split(',');
    _prefs.setStringList("status", chnagedtolist);
  }
   getAsTask()async{
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
  final List<String> items = _prefs.getStringList('task')??[];
    print(items);
 return items;
}
getAsBool() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final List<String> items = _prefs.getStringList('status')??[];
    List<bool> boolList = [for (String item in items) item.toLowerCase() == "true"];

    return boolList;
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }


  Future _showTextField (BuildContext context,String title,bool trum,int indx) async{

    return showDialog(context: context, builder: (context) {

      return AlertDialog(
        title: Text(title,style: TextStyle(color: Colors.deepOrange ,fontSize: 20)),
        content: TextField(
          controller: myController,
          onChanged: (valuetxt){
            AddTask=valuetxt;
          },
          decoration: InputDecoration(
            hintText: "Type Task Here",
            enabledBorder: new OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1.0))
          ),

        ),
        actions: [
          ElevatedButton(onPressed: ()=> Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(onPressed: () async {
            setState(() {
              if(!trum){
              addlist(AddTask!);

              }

              else {
                TodoList[indx] = AddTask!;

              }}

            );
            await saveAsList(TodoList);
             await saveAsBool(TodoListCheck);

            Navigator.pop(context);
            },
              child: Text("Submit"))
        ],
      );
    });
  }

void addlist(String val){
  TodoList.add(val);
  TodoListCheck.add(false);
}
  @override
  Widget build(BuildContext context) {
    return  mailScaffold();
  }

  Scaffold mailScaffold() {
    return Scaffold(
    appBar: AppBar(
      flexibleSpace: SafeArea(child: Center(child: Text("Tasks: "+TodoList.length.toString(),style: TextStyle(color: Colors.white,fontSize: 23),))),
      title: const Text("To Do List" , style: TextStyle(
          color: Colors.white
      ),),
      backgroundColor: Colors.lightBlueAccent,
      actions: [


        IconButton(onPressed: (){
          myController.clear();
          _showTextField(context,"Add Task",false,0);
          }, icon: Icon(Icons.add_task,
            color: Colors.white,size: 35))
      ],
    ),
      body: SafeArea(child: TodoList.length!=0?Items():NotFound()),
  );
  }

  Center NotFound() {
   return Center(child: Container(
     padding: EdgeInsets.all(40),
     decoration: BoxDecoration(
       color: Colors.red.withOpacity(0.80),
           borderRadius: BorderRadius.circular(10)
     ),
       child: Text("Task Not Found" ,style: TextStyle(
         color: Colors.white,
         fontSize: 30
       ),)
   ));
  }

  Padding Items() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: TodoList.length,//TODO: Errorhere
        itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.only(top: 4.0,bottom: 4.0),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
                color: Colors.lightGreenAccent
              ),
              child: Row(

                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blueAccent,

                      value: TodoListCheck[index], onChanged: (vsl){
                        setState(() {
                          TodoListCheck[index]=vsl!;
                          saveAsBool(TodoListCheck);
                        });

                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(TodoList[index].toUpperCase() ,style: TextStyle(
                        fontSize: 20,color: Colors.blueAccent,
                    decoration: TodoListCheck[index]==true?TextDecoration.lineThrough:TextDecoration.none,
                      decorationThickness: 3,
                    ),),
                  ),
                  Spacer(),
                  IconButton(onPressed: (){
                    setState(() {
                      _showTextField(context,"Edit Task",true,index);
                      myController.text=TodoList[index];
                    });

                  }, icon: Icon(Icons.edit,color: Colors.red.shade400,size: 28,)),
                  IconButton(onPressed: () async{
                    setState(() {
                      TodoList.removeAt(index);
                    });
                    await saveAsList(TodoList);
                    await saveAsBool(TodoListCheck);
                  }, icon: Icon(Icons.delete,color: Colors.red,size: 30,)),


                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
