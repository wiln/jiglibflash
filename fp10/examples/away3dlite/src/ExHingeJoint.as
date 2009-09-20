package
{
	import away3dlite.materials.ColorMaterial;
	import away3dlite.materials.WireframeMaterial;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.math.*;
	import jiglib.physics.*;
	import jiglib.physics.constraint.*;
	import jiglib.plugin.away3dlite.Away3DLiteMesh;
	import away3dlite.templates.PhysicsTemplate;

	[SWF(backgroundColor="#666666",frameRate="30",quality="MEDIUM",width="800",height="600")]
	/**
	 * Example : Physics HingeJoint
	 *
	 * @see http://away3d.googlecode.com/svn/trunk/fp10/Away3DLite/src
	 * @see http://jiglibflash.googlecode.com/svn/trunk/fp10/src
	 *
	 * @author katopz
	 */
	public class ExHingeJoint extends PhysicsTemplate
	{
		private var boxBody:Array;

		private var onDraging:Boolean = false;

		private var currDragBody:RigidBody;
		private var dragConstraint:JConstraintWorldPoint;
		private var planeToDragOn:Vector3D;

		private var startMousePos:Vector3D;

		private var chain:Array;

		override protected function build():void
		{
			title += " | HingeJoint : Use mouse to drag red ball | ";

			camera.y = -1000;

			init3D();

			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);

			JConfig.limitLinVelocities = 200;
			JConfig.numContactIterations = 8;
		}

		private function init3D():void
		{
			// TODO: use object hit instead of layer
			var layer:Sprite = new Sprite();
			view.addChild(layer);

			var sphere:RigidBody;
			var prevSphere:RigidBody;

			chain = [];
			for (var i:int = 0; i < 8; i++)
			{
				if (i == 0)
				{
					sphere = physics.createSphere(new ColorMaterial(0xFF0000), 20, 3, 2);

					// draggable
					currDragBody = sphere;
					Away3DLiteMesh(sphere.skin).mesh.layer = layer;
				}
				else
				{
					sphere = physics.createSphere(new WireframeMaterial(), 20, 3, 2);
				}

				sphere.moveTo(new Vector3D(0, 130 + (25 * i + 25), 0));

				if (i != 0)
				{
					var pos1:Vector3D = JNumber3D.getScaleVector(JNumber3D.UP, -prevSphere.boundingSphere);
					var pos2:Vector3D = JNumber3D.getScaleVector(JNumber3D.UP, sphere.boundingSphere);

					//set up the hinge joints.
					chain[i] = new HingeJoint(prevSphere, sphere, Vector3D.X_AXIS, new Vector3D(0, 15, 0), 10, 30, 30, 0.1, 0.5);

					//disable some collisions between adjacent pairs
					sphere.disableCollisions(prevSphere);
				}

				prevSphere = sphere;
			}

			boxBody = [];
			for (i = 0; i < 10; i++)
			{
				boxBody[i] = physics.createCube(new WireframeMaterial(0xFFFFFF * Math.random()), 25, 25, 25);
				boxBody[i].moveTo(new Vector3D(500 * Math.random() - 500 * Math.random(), 500 + 500 * Math.random(), 500 * Math.random() - 500 * Math.random()));
			}

			layer.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
		}

		private function handleMousePress(event:MouseEvent):void
		{
			onDraging = true;
			var layer:Sprite = event.target as Sprite;

			startMousePos = new Vector3D(currDragBody.x, currDragBody.y, currDragBody.z);

			planeToDragOn = JMath3D.fromNormalAndPoint(new Vector3D(0, 1, 0), new Vector3D(0, 0, -startMousePos.z));

			var p:Vector3D = currDragBody.currentState.position;
			var bodyPoint:Vector3D = startMousePos.subtract(new Vector3D(p.x, p.y, p.z));

			var a:Vector3D = new Vector3D(bodyPoint.x, bodyPoint.y, bodyPoint.z);
			var b:Vector3D = new Vector3D(startMousePos.x, startMousePos.y, startMousePos.z);

			dragConstraint = new JConstraintWorldPoint(currDragBody, a, b);
			physics.engine.addConstraint(dragConstraint);
		}

		// TODO:clean up/by pass
		private function handleMouseMove(event:MouseEvent):void
		{
			if (onDraging)
			{
				var ray:Vector3D = JMath3D.unproject(camera.transform.matrix3D, camera.focus , camera.zoom, view.mouseX, -view.mouseY);
				ray.add(new Vector3D(view.camera.x, view.camera.y, view.camera.z));

				var cameraVector3D:Vector3D = new Vector3D(view.camera.x, view.camera.y, view.camera.z);
				var rayVector3D:Vector3D = new Vector3D(ray.x, ray.y, ray.z);
				var intersectPoint:Vector3D = JMath3D.getIntersectionLine(planeToDragOn, cameraVector3D, rayVector3D);

				dragConstraint.worldPosition = new Vector3D(intersectPoint.x, intersectPoint.y, intersectPoint.z);
			}
		}

		private function handleMouseRelease(event:MouseEvent):void
		{
			if (onDraging)
			{
				onDraging = false;
				physics.engine.removeConstraint(dragConstraint);
				currDragBody.setActive();
			}
		}
		
		override protected function onPreRender():void
		{
			//run
			physics.step();

			//system
			camera.lookAt(Away3DLiteMesh(ground.skin).mesh.position, new Vector3D(0, -1, 0));
		}
	}
}