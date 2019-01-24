package om.loop;

#if js

import js.Browser.console;
import om.Time;

/**
	Game loop with fixed timestep
**/
class MainLoop {

	public var timestep(default,null) : Float;
	public var started(default,null) = false;
	public var running(default,null) = false;

	public var begin : Float->Float->Void;
	public var update : Float->Void;
	public var render : Float->Void;
	//public var end : Float->Void; //TODO

	var frameDelta : Float;
	var lastFrameTimeMs : Float;
	var minFrameDelay = 0.0;
	var numUpdateSteps : Int;
	var panic = false;
	var rafId : Int;

	//var fps = 60.0;
	//var fpsAlpha = 0.9;
	//var fpsUpdateInterval = 1000;
	//var lastFpsUpdate = 0.0;
	//var framesSinceLastFpsUpdate = 0;

	public function new( timestep : Float, begin : Float->Float->Void, update : Float->Void, render : Float->Void ) {
		this.timestep = timestep;
		this.begin = begin;
		this.update = update;
		this.render = render;
		//this.end = end;
	}

	public function start() {
		if( !started ) {
			started = true;
			frameDelta = lastFrameTimeMs = 0;
			raf( function(time) {
				render( 1 );
				running = true;
				lastFrameTimeMs = time;
				//lastFpsUpdate = time;
				//framesSinceLastFpsUpdate = 0;
				rafId = raf( frame );
			});
		}
		return this;
	}

	public function stop() {
		if( running ) {
			running = started = false;
			js.Browser.window.cancelAnimationFrame( rafId );
		}
		return this;
	}

	function frame( timestamp : Float ) {

		//console.time('frame');

		rafId = raf( frame );

		if( timestamp < lastFrameTimeMs + minFrameDelay )
		 	return;

		frameDelta += timestamp - lastFrameTimeMs;
		lastFrameTimeMs = timestamp;

		//console.time('begin');
		begin( timestamp, frameDelta );
		//console.timeEnd('begin');

		/*
		if( timestamp > lastFpsUpdate + fpsUpdateInterval ) {
			fps = fpsAlpha * framesSinceLastFpsUpdate * 1000 / (timestamp - lastFpsUpdate) + (1 - fpsAlpha) * fps;
			lastFpsUpdate = timestamp;
			framesSinceLastFpsUpdate = 0;
		}
		framesSinceLastFpsUpdate++;
		*/
		//console.time('update');
		numUpdateSteps = 0;
		while( frameDelta >= timestep ) {
			update( timestep );
			frameDelta -= timestep;
			if( ++numUpdateSteps >= 240 ) {
				panic = true;
            	break;
			}
		}
		//console.log(numUpdateSteps);
		//console.timeEnd('update');

		//console.time('render');
		//inline render( frameDelta / timestep );
		render( frameDelta / timestep );
		//console.timeEnd('render');

		//end( fps, panic );

		panic = false;

		//console.timeEnd('frame');
	}

	static inline function raf( f : Float->Void )
		return js.Browser.window.requestAnimationFrame( f );

}

#end
