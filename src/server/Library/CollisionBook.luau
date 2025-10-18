--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local PS = game:GetService("PhysicsService")

local Book = {
	Group = {
		Hitbox = "Hitbox",

		PlayerBodyPart = "PlayerBodyPart",
		EnemyBodyPart = "EnemyBodyPart",
		NPCBodyPart = "NPCBodyPart",

		PlayerProjectile = "PlayerProjectile",
		EnemyProjectile = "EnemyProjectile",

		NoCollision = "NoCollision",
	},
}


PS:RegisterCollisionGroup(Book.Group.Hitbox)
PS:RegisterCollisionGroup(Book.Group.PlayerBodyPart)
PS:RegisterCollisionGroup(Book.Group.EnemyBodyPart)
PS:RegisterCollisionGroup(Book.Group.NPCBodyPart)
PS:RegisterCollisionGroup(Book.Group.PlayerProjectile)
PS:RegisterCollisionGroup(Book.Group.EnemyProjectile)
PS:RegisterCollisionGroup(Book.Group.NoCollision)


PS:CollisionGroupSetCollidable(Book.Group.Hitbox, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.PlayerBodyPart, true)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.Hitbox, Book.Group.NoCollision, false)


PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.Hitbox, true)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.PlayerBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.EnemyProjectile, true)
PS:CollisionGroupSetCollidable(Book.Group.PlayerBodyPart, Book.Group.NoCollision, false)


PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.PlayerBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.PlayerProjectile, true)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyBodyPart, Book.Group.NoCollision, false)


PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.PlayerBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.NPCBodyPart, Book.Group.NoCollision, false)


PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.PlayerBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.EnemyBodyPart, true)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.PlayerProjectile, Book.Group.NoCollision, false)


PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, "Default", true)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.PlayerBodyPart, true)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.EnemyProjectile, Book.Group.NoCollision, false)



PS:CollisionGroupSetCollidable(Book.Group.NoCollision, "Default", false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.Hitbox, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.PlayerBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.EnemyBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.NPCBodyPart, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.PlayerProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.EnemyProjectile, false)
PS:CollisionGroupSetCollidable(Book.Group.NoCollision, Book.Group.NoCollision, false)


return Book