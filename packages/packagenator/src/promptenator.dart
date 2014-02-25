part of packagenator;

class Promptenator{
	final streams.Streamable ioStream = streams.Streamable.create();
	final streams.Streamable errStream = streams.Streamable.create();
	final Switch echo = Switch.create();
	IOSink io;

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

	void shutdown(){
		this.io.close();
		this.ioStream.close();
		this.errStream.close();
		this.io = null;
		this.echo.close();
	}
}