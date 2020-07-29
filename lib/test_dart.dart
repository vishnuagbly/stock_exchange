import 'dart:async';

Future<void> newFunction() async {
  print("enter newFunction()");
  int i = 3;
  print("alternative Program is sleeping");
  Future.delayed(Duration(seconds: 20), () {
    print("alternative program slept like a baby");
  });
  while(i-- > 0){
    print("trying get this function to sleep");
    await Future.delayed(Duration(seconds: 2), () {
      print("program slept like a baby");
    });
    print("doing other stuff after program is slept");
  }
}

void main() async {
  print("first line");
  await newFunction();
  print("third line");
}