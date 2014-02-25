library packagenator.spec;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';


void main(){

	print('#Welcome to prompt Galor!');
	var prompt = Promptenator.create(stdin);

	prompt.on((n){
		print('prompts:: $n');
	});

	prompt.boot();
}