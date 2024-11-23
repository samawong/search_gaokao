import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/db_helper.dart';


void main() {

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(HighSchoolQueryApp());
}

class HighSchoolQueryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentQueryScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class StudentQueryScreen extends StatefulWidget {
  @override
  _StudentQueryScreenState createState() => _StudentQueryScreenState();
}

class _StudentQueryScreenState extends State<StudentQueryScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _students = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _insertSampleData();
    _loadStudents();
  }

  Future<void> _insertSampleData() async {
    await _dbHelper.insertSampleData();
  }

  Future<void> _loadStudents() async {
    final students = await _dbHelper.queryStudents();
    setState(() {
      _students = students;
    });
  }

  Future<void> _filterStudents() async {
    String searchQuery = _searchController.text.trim();

    // 将用户输入的查询条件分割（按逗号或空格分隔）
    List<String> searchTerms =
        searchQuery.split(RegExp(r'[,\s]+')).map((e) => e.trim()).toList();

    // 调用数据库查询方法
    final students = await _dbHelper.searchStudentsByKeywords(searchTerms);

    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 上下居中对齐
        crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中
        children: [
          SizedBox(height: 200.0),
          Text(
            '河南省普通高招录取学生信息查询',
            style: TextStyle(fontSize: 64.0, fontWeight: FontWeight.bold),
          ),
          Text(
            '（1978-1996）',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
          SizedBox(height: 20.0), // 增加一些间距
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 30.0,),
                decoration: InputDecoration(
                  labelText: '输入查询条件（姓名, 年份, 学校等）',
                  labelStyle: TextStyle(fontSize: 28.0,),
                  border: OutlineInputBorder(),
                ),
              onChanged: (value) {
                _filterStudents(); // 实时搜索
              },
              ),
            ),

          ),
          SizedBox(height: 20.0),
          Expanded(
            child: Center(
              child:SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 600.0,
                child: ListView.builder(
                itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child:Padding(
                        padding: EdgeInsets.all(12.0),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text('姓名: ${student['name']}',style: TextStyle(fontSize: 35.0,),),
                            SizedBox(height: 8.0),
                            Text('籍贯: ${student['nativePlace']}',style: TextStyle(fontSize: 35.0,),),
                            Text('高考年份: ${student['examYear']}',style: TextStyle(fontSize: 35.0,),),
                            Text('录取学校: ${student['admittedUniversity']}',style: TextStyle(fontSize: 35.0,),),
                            Text('毕业高中: ${student['highSchool']}',style: TextStyle(fontSize: 35.0,),),
                          ]
                        )
                      ),
                      
                    );
                  },
                ),
              ),
            ),
          ),
        
        ],
      ),
      
    );
  }
}
