package om;

import js.Browser.window;

class Loop {

    public var beforeCallback : Float->Void;
    public var updateCallback : Float->Void;
    public var renderCallback : Float->Void;
    public var afterCallback : Float->Void;
    public var panicCallback : Int->Void;

    /** The amount of time (in milliseconds) to simulate each time update() runs. */
    public var timestep : Float; // 1000/60;

    /** */
    public var running(default,null) = false;

    /** */
    public var maxUpdateSteps : Int;

    //public var timeStart(default,null) : Float;
    //public var timeElapsed(default,null) : Float;
    //public var framesRendered(default,null) : Int;

    var lastFrameTime : Float;
    var delta : Float;
    var numUpdateSteps : Int;
    var frameId : Int;

    public function new( timestep = 1000/60, maxUpdateSteps = 60 ) {
        this.timestep = timestep;
        this.maxUpdateSteps = maxUpdateSteps;
    }

    public function start( ?updateCallback : Float->Void, ?renderCallback : Float->Void, ?panicCallback : Int->Void ) : Loop {

        if( running ) stop();

        if( updateCallback != null ) this.updateCallback = updateCallback;
        if( renderCallback != null ) this.renderCallback = renderCallback;
        if( panicCallback != null ) this.panicCallback = panicCallback;

        running = true;
        delta = 0.0;
        lastFrameTime = Time.now();

        frameId = window.requestAnimationFrame( tick );

        return this;
    }

    public function stop() : Loop {

        if( !running )
            return this;

        running = false;
        window.cancelAnimationFrame( frameId );
        frameId = null;

        return this;
    }

    function tick( time : Float ) {

        delta += time - lastFrameTime;
        lastFrameTime = time;

        //if( beforeCallback != null ) beforeCallback( timestep );

        numUpdateSteps = 0;

        while( delta >= timestep ) {
            if( updateCallback != null ) updateCallback( timestep );
            if( ++numUpdateSteps >= maxUpdateSteps ) {
                if( panicCallback != null ) panicCallback( numUpdateSteps );
                delta = 0;
                break;
            } else {
                delta -= timestep;
            }
        }

        if( renderCallback != null ) renderCallback( timestep );

        //framesRendered++;

        //if( afterCallback != null ) afterCallback( timestep );

        frameId = js.Browser.window.requestAnimationFrame( tick );
    }

}
