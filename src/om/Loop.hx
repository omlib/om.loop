package om;

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

    #if js
    var frameId : Int;
    #end

    public function new( timestep = 1000/60, maxUpdateSteps = 60 ) {
        this.timestep = timestep;
        this.maxUpdateSteps = maxUpdateSteps;
    }

    public function start( ?updateCallback : Float->Void, ?renderCallback : Float->Void, ?panicCallback : Int->Void ) {

        if( running )
            return;

        this.updateCallback = updateCallback;
        this.renderCallback = renderCallback;
        this.panicCallback = panicCallback;

        running = true;
        delta = 0.0;
        lastFrameTime = Time.now();

        #if js
        frameId = js.Browser.window.requestAnimationFrame( tick );
        #elseif nme
        nme.Lib.current.stage.addEventListener( nme.events.Event.ENTER_FRAME, onEnterFrame );
        #end
    }

    public function stop() {

        if( !running )
            return;

        running = false;

        #if js
        js.Browser.window.cancelAnimationFrame( frameId );
        frameId = null;

        #elseif nme
        nme.Lib.current.stage.removeEventListener( nme.events.Event.ENTER_FRAME, onEnterFrame );

        #end
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

        #if js
        frameId = js.Browser.window.requestAnimationFrame( tick );
        #end
    }

    #if nme

    function onEnterFrame( e : nme.events.Event ) {
        tick( Timer.stamp() );
    }

    #end

}
