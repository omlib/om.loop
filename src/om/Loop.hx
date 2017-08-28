package om;

class Loop {

    //public var beginCallback : Float->Void;
    public var updateCallback : Float->Void;
    public var renderCallback : Float->Void;
    //public var endCallback : Float->Void;
    public var panicCallback : Int->Void;

    public var running(default,null) = false;

    //public var timeStart(default,null) : Float;
    //public var timeElapsed(default,null) : Float;
    public var lastFrameTime(default,null) : Float;

    /**
        The amount of time (in milliseconds) to simulate each time update() runs.
    */
    public var timestep : Float; // 1000/60;

    /**
    */
    public var panic : Int;

    var delta : Float;

    #if js
    var frameId : Int;
    #end

    public function new( timestep = 1000/60, panic = 240 ) {
        this.timestep = timestep;
        this.panic = panic;
    }

    public function start( ?updateCallback : Float->Void, ?renderCallback : Float->Void, ?panicCallback : Int->Void ) {

        if( running )
            return;

        this.updateCallback = updateCallback;
        this.renderCallback = renderCallback;
        this.panicCallback = panicCallback;

        running = true;
        delta = 0.0;
        //timeStart =
        lastFrameTime = Time.now();

        #if js
        frameId = js.Browser.window.requestAnimationFrame( run );

        #elseif nme
        nme.Lib.current.stage.addEventListener( nme.events.Event.ENTER_FRAME, run );

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
        nme.Lib.current.stage.removeEventListener( nme.events.Event.ENTER_FRAME, run );

        #end
    }

    #if js
    function run( _time : Float ) {
    #elseif nme
    function run( e : nme.events.Event ) {
    #end

        var now = Time.stamp();
        //timeElapsed = now - timeStart;
        delta += now - lastFrameTime;
        lastFrameTime = now;

        //if( beginCallback != null ) beginCallback();

        var i = 0;
        while( delta >= timestep ) {
            if( updateCallback != null ) updateCallback( timestep );
            if( ++i >= panic ) {
                trace( 'PANIC '+i ); // fix things
                if( panicCallback != null ) panicCallback( i );
                delta = 0;
                break;
            } else {
                delta -= timestep;
            }
        }

        if( renderCallback != null ) renderCallback( timestep );

        //if( endCallback != null ) endCallback();

        #if js
        frameId = js.Browser.window.requestAnimationFrame( run );
        #end
    }

}
