package jiglib.cof {

	public class JConfig {
		
		public static var solverType:String = "NORMAL";//allowable value: FAST,NORMAL,ACCUMULATED
		public static var detectCollisionsType:String = "DIRECT";//allowable value: DIRECT or STORE
		public static var boxCollisionsType:String = "EDGEBASE";//allowable value: EDGEBASE or SORTBASE
		
		public static var doShockStep:Boolean = true;//if do a shock step to help stacking
		public static var allowedPenetration:Number = 0.001;// How much penetration to allow
		public static var collToll:Number = 0.05;// the tolerance for collision detection 
		public static var velThreshold:Number = 0.3;
		public static var angVelThreshold:Number = 0.3;
		public static var posThreshold:Number = 0.2;// change for detecting position changes during deactivation
		public static var orientThreshold:Number = 0.2;// change for detecting orientation changes during deactivation.
		public static var deactivationTime:Number = 0.5;// how long it takes to go from active to frozen when stationary.
		public static var numPenetrationRelaxationTimesteps:Number = 10;// number of timesteps to resolve penetration over
		public static var numCollisionIterations:Number = 4;// number of collision iterations
		public static var numContactIterations:Number = 8;// number of contact iteratrions
	}
}
