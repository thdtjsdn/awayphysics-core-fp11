package awayphysics.dynamics
{
	import awayphysics.AWPBase;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.dynamics.constraintsolver.AWPTypedConstraint;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	import awayphysics.math.AWPVector3;
	import flash.geom.Vector3D;


	public class AWPDynamicsWorld extends AWPBase
	{
		private static var currentDynamicsWorld : AWPDynamicsWorld;
		private var m_gravity : AWPVector3;
		private var m_rigidBodies : Vector.<AWPRigidBody>;
		private var m_nonStaticRigidBodies : Vector.<AWPRigidBody>;
		private var m_vehicles : Vector.<AWPRaycastVehicle>;
		private var m_characters : Vector.<AWPKinematicCharacterController>;

		public static function getInstance() : AWPDynamicsWorld
		{
			if (!currentDynamicsWorld) {
				trace("version: BulletFlash v0.62 alpha (16-8-2011)");
				currentDynamicsWorld = new AWPDynamicsWorld();
			}
			return currentDynamicsWorld;
		}

		public function AWPDynamicsWorld()
		{
			AWPBase.initialize();

			m_rigidBodies = new Vector.<AWPRigidBody>();
			m_nonStaticRigidBodies = new Vector.<AWPRigidBody>();
			m_vehicles = new Vector.<AWPRaycastVehicle>();
			m_characters = new Vector.<AWPKinematicCharacterController>();
		}

		// init the physics world with btDbvtBroadphase
		// refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Broadphase
		public function initWithDbvtBroadphase() : void
		{
			pointer = bullet.createDiscreteDynamicsWorldWithDbvtMethod();
			m_gravity = new AWPVector3(pointer + 224);
			this.gravity = new Vector3D(0, -10, 0);
		}

		// init the physics world with btAxisSweep3
		// refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Broadphase
		public function initWithAxisSweep3(worldAabbMin : Vector3D, worldAabbMax : Vector3D) : void
		{
			pointer = bullet.createDiscreteDynamicsWorldWithAxisSweep3Method(worldAabbMin.x / _scaling, worldAabbMin.y / _scaling, worldAabbMin.z / _scaling, worldAabbMax.x / _scaling, worldAabbMax.y / _scaling, worldAabbMax.z / _scaling);
			m_gravity = new AWPVector3(pointer + 224);
			this.gravity = new Vector3D(0, -10, 0);
		}

		// add a rigidbody to physics world
		public function addRigidBody(body : AWPRigidBody) : void
		{
			bullet.addBodyMethod(body.pointer);

			if (body.collisionFlags != AWPCollisionFlags.CF_STATIC_OBJECT) {
				if (m_nonStaticRigidBodies.indexOf(body) < 0) {
					m_nonStaticRigidBodies.push(body);
				}
			}
			if (m_rigidBodies.indexOf(body) < 0) {
				m_rigidBodies.push(body);
			}
		}

		// add a rigidbody to physics world with group and mask
		// refer to: http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Filtering
		public function addRigidBodyWithGroup(body : AWPRigidBody, group : int, mask : int) : void
		{
			bullet.addBodyWithGroupMethod(body.pointer, group, mask);

			if (body.collisionFlags != AWPCollisionFlags.CF_STATIC_OBJECT) {
				if (m_nonStaticRigidBodies.indexOf(body) < 0) {
					m_nonStaticRigidBodies.push(body);
				}
			}
			if (m_rigidBodies.indexOf(body) < 0) {
				m_rigidBodies.push(body);
			}
		}

		// remove a rigidbody from physics world
		public function removeRigidBody(body : AWPRigidBody) : void
		{
			bullet.removeBodyMethod(body.pointer);

			if (m_nonStaticRigidBodies.indexOf(body) >= 0) {
				m_nonStaticRigidBodies.splice(m_nonStaticRigidBodies.indexOf(body), 1);
			}
			if (m_rigidBodies.indexOf(body) >= 0) {
				m_rigidBodies.splice(m_rigidBodies.indexOf(body), 1);
			}
		}

		public function addConstraint(constraint : AWPTypedConstraint, disableCollisionsBetweenLinkedBodies : Boolean = false) : void
		{
			bullet.addConstraintMethod(constraint.pointer, disableCollisionsBetweenLinkedBodies ? 1 : 0);
		}

		public function removeConstraint(constraint : AWPTypedConstraint) : void
		{
			bullet.removeConstraintMethod(constraint.pointer);
		}

		public function addVehicle(vehicle : AWPRaycastVehicle) : void
		{
			bullet.addVehicleMethod(vehicle.pointer);

			if (m_vehicles.indexOf(vehicle) < 0) {
				m_vehicles.push(vehicle);
			}
		}

		public function removeVehicle(vehicle : AWPRaycastVehicle) : void
		{
			bullet.removeVehicleMethod(vehicle.pointer);

			if (m_vehicles.indexOf(vehicle) >= 0) {
				m_vehicles.splice(m_vehicles.indexOf(vehicle), 1);
			}
		}

		public function addCharacter(character : AWPKinematicCharacterController, group : int = 32, mask : int = -1) : void
		{
			bullet.addCharacterMethod(character.pointer, group, mask);

			if (m_characters.indexOf(character) < 0) {
				m_characters.push(character);
			}
		}

		public function removeCharacter(character : AWPKinematicCharacterController) : void
		{
			bullet.removeCharacterMethod(character.pointer);

			if (m_characters.indexOf(character) >= 0) {
				m_characters.splice(m_characters.indexOf(character), 1);
			}
		}

		// get the gravity of physics world
		public function get gravity() : Vector3D {
			return m_gravity.v3d;
		}

		// set the gravity of physics world
		public function set gravity(g : Vector3D) : void {
			m_gravity.v3d = g;
			for each (var body:AWPRigidBody in m_nonStaticRigidBodies) {
				body.gravity = g;
			}
		}

		// get all rigidbodies
		public function get rigidBodies() : Vector.<AWPRigidBody> {
			return m_rigidBodies;
		}

		// get all non static rigidbodies
		public function get nonStaticRigidBodies() : Vector.<AWPRigidBody> {
			return m_nonStaticRigidBodies;
		}

		public function get vehicles() : Vector.<AWPRaycastVehicle> {
			return m_vehicles;
		}

		public function get characters() : Vector.<AWPKinematicCharacterController> {
			return m_characters;
		}

		// set physics world scaling
		// refer to http://www.bulletphysics.org/mediawiki-1.5.8/index.php?title=Scaling_The_World
		public function set scaling(v : Number) : void {
			_scaling = v;
		}

		// get physics world scaling
		public function get scaling() : Number {
			return _scaling;
		}

		// get/set if implement object collision callback
		public function get collisionCallbackOn() : Boolean {
			return memUser._mru8(pointer + 247) == 1;
		}

		public function set collisionCallbackOn(v : Boolean) : void {
			memUser._mw8(pointer + 247, v ? 1 : 0);
		}

		// set time step and simulate the physics world
		// refer to: http://bulletphysics.org/mediawiki-1.5.8/index.php/Stepping_the_World
		public function step(timeStep : Number, maxSubSteps : int = 1, fixedTimeStep : Number = 1.0 / 60) : void
		{
			bullet.stepMethod(timeStep, maxSubSteps, fixedTimeStep);

			for each (var body:AWPRigidBody in m_nonStaticRigidBodies) {
				body.updateTransform();
			}

			for each (var vehicle:AWPRaycastVehicle in m_vehicles) {
				vehicle.updateWheelsTransform();
			}

			for each (var character:AWPKinematicCharacterController in m_characters) {
				character.updateTransform();
			}
		}
	}
}