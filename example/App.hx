
import js.Browser.document;
import js.Browser.window;
import js.html.DivElement;
import om.Time;
import om.Loop;

class App {

	static var loop : Loop;

	static var info_time : DivElement;
	static var info_loop : DivElement;
	static var info_frame : DivElement;
	static var info_update : DivElement;
	static var info_render : DivElement;

	static var frame = 0;

	static function update( delta : Float ) {

		frame++;

		info_time.textContent = 'TIME: '+Std.int( Time.stamp() );
		info_loop.textContent = 'LOOP: '+loop.timestep;
		info_frame.textContent = 'FRAME: '+frame;
		info_update.textContent = 'DELTA: '+delta;
	}

	static function render( delta : Float ) {
		info_render.textContent = 'RENDER: '+delta;
	}

	static function main() {

		window.onload = function(_) {

			info_time = cast document.getElementById( 'info_time' );
			info_loop = cast document.getElementById( 'info_loop' );
			info_frame = cast document.getElementById( 'info_frame' );
			info_update = cast document.getElementById( 'info_update' );
			info_render = cast document.getElementById( 'info_render' );

			loop = new Loop( 1000/60 );
			loop.start( update, render );
		}
	}
}
