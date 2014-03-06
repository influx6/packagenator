part of packagenator.core;

class Promptenator{
	//the outstream is not generally used,but its added hear for future functionality like
	// creating a custom output for the prompt
	final streams.Streamable outStream = streams.Streamable.create();
	final streams.Streamable ioStream = streams.Streamable.create();
	final streams.Streamable errStream = streams.Streamable.create();
	final Switch echo = Switch.create();
	Stdin io;

	static create(io) => new Promptenator(io);

	Promptenator(this.io){
		this.ioStream.transformer.on(UTF8.decode);
		this.echo.onOn.add((){ this.io.echoMode = true; });
		this.echo.onOff.add((){ this.io.echoMode = false; });
		this.echo.switchOn();
	}

	void on(Function n){
		this.ioStream.on(n);
	}

	void off(Function n){
		this.ioStream.off(n);
	}

	void onError(Function n){
		this.errStream.on(n);
	}

	void offError(Function n){
		this.errStream.off(n);
	}

	void boot(){
		this.io.listen(this.ioStream.emit,onError:(e,s){
			this.errStream.emit({'e':e,'stack': s});
		},onDone: this.shutdown);
	}

	void shutdown([bool force]){
		force = Funcs.switchUnless(force,false);
		this.ioStream.close();
	    this.errStream.close();
	    this.outStream.close();
	    this.echo.close();
	    if(force) return exit(0);
	    this.io = null;
	}
}

class Prompter extends Promptenator{
	final MapDecorator qrequests = new MapDecorator();
	final MapDecorator qanswers = new MapDecorator();
	final RegExp qReg = new RegExp(r'{{question}}');
	final RegExp sideReg = new RegExp(r'{{sidenote}}');
	String template ="{{question}}:\t\t\t\t-->({{sidenote}})";
	Function whenFinished;
	List _keypool;

	static create(n,m) => new Prompter(n,m);

	Prompter(n,this.whenFinished): super(n);

	void setOut(Function n){
		this.outStream.on(n);
	}

	void reset(){ 
		this.qanswers.flush();
		this.qrequests.flush(); 
	}

	void question(String question,[String sidenote,Function validator,String failmesg]){
		this.qrequests.add(question,{
			'q':question,
			'f': Funcs.switchUnless(failmesg,'supplied value does not match requirements'),
			'sd': Funcs.switchUnless(sidenote,''),
			'fn': Funcs.switchUnless(validator,(n){
				if(Valids.exist(n) && (n is String && !n.isEmpty)) return true;
				return false;
			})
		});
	}

	void optionalQuestion(String question,[String sidenote,Function validator,String failmessage]){
		this.question(question,sidenote,(n){
			if(Valids.exist(n) && (Valids.exist(validator) && validator(n))) return true;
			return true;
		},failmessage);
	}

	void askNext(){
		if(this._keypool.isEmpty){
		  this.whenFinished(new Map.from(this.qanswers.storage));
      	  this.shutdown();
      	  return;
		}
		var q = this.qrequests.get(Enums.first(this._keypool));
		var finder = Enums.nthFor(q);
		var tmpl = this.template.replaceAll(this.sideReg,finder('sd')).replaceAll(qReg,finder('q'));
		this.outStream.emit('\n');
		this.outStream.emit(tmpl);
	}

	void answer(dynamic n){
		var q = this.qrequests.get(Enums.first(this._keypool));
		var finder = Enums.nthFor(q);
		if(!finder('fn')(n)) return this.outStream.emit(finder('f'));
		this.qanswers.add(finder('q'),n);
		this._keypool = this._keypool.sublist(1, this._keypool.length);
		this.askNext();
	}

	void boot(){
		this._keypool = this.qrequests.storage.keys.toList();
		this.ioStream.on(this.answer);
	    super.boot();
		this.askNext();
	}

}