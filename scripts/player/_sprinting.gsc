init()
{
	Settings();
	
	[[level.addCallback]]("onConnect", ::RunOnConnect);
	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);
}

Settings()
{
	// Which sprint weapon to use?
	level.sprintweapon_slow = "sprint_slow_mp";
	level.sprintweapon_med = "sprint_med_mp";
	level.sprintweapon_fast = "sprint_fast_mp";

	// AWE Sprinting
	level.sprint 			= game["bz_sprint"];
	if(! level.sprint) return;

	level.sprinttime 		= game["bz_sprint_time"] * 20;
	level.sprintrecovertime	= game["bz_sprint_recovertime"] * 20;

	// Precache
	[[level.r_precacheItem]](level.sprintweapon_slow);
	[[level.r_precacheItem]](level.sprintweapon_med);
	[[level.r_precacheItem]](level.sprintweapon_fast);
}

RunOnConnect()
{
	self._sprinttime = level.sprinttime;
	self._sprintweapon = level.sprintweapon_slow;
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self._sprinttime = 0;
	self._sprinting = false;
}

RunOnSpawn()
{
	self thread MonitorSprinting();
}

MonitorSprinting()
{
	self endon("disconnect");
	self endon("killed_player");

	if (! level.sprint)
		return;

	self.sprinting = false;

	_cW	= self getCurrentWeapon();
	_pW = self getWeaponSlotWeapon( "primary" );
	_pW_ammo = self getWeaponSlotAmmo( "primary" );
	_pW_clip = self getWeaponSlotClipAmmo( "primary" );

	playbreathsound = false;
	recovertime = 0;
	ammo = 100;

	while ( isAlive( self ) && self.sessionstate == "playing" ) // amíg élek
	{
		sprint = ( level.sprinttime - self._sprinttime ) / level.sprinttime; // [0;1], 0->1
		oldorigin = self.origin;

		// Wait
		wait 0.05;

		// ha minden sprinthez szükséges feltétel igaz
		if ( oldorigin != self.origin && self useButtonPressed() && self._sprinttime > 0 )
		{
			// ha még nem sprintel
			if ( ! self.sprinting )
			{
				cW = self getCurrentWeapon(); // current weapon
				pW = self getWeaponSlotWeapon( "primary" ); // current slot weapon

				// ha az aktuális fegyver "none"
				if ( cW == "none" )
					continue;

					_pW = pW;
					_pW_ammo = self getWeaponSlotAmmo( "primary" );
					_pW_clip = self getWeaponSlotClipAmmo( "primary" );

					if ( cW != self._sprintweapon )
						_cW = cW;
					else
						_cW = pW;

				// biztos sprintelni akar?
				buttoncount = 0;
				while ( self useButtonPressed() && buttoncount < 5)
				{
					buttoncount++;
					wait 0.05;
				}
				if ( buttoncount < 5 )
					continue;

				// sprintet fegyverként beállítja
				self setWeaponSlotWeapon( "primary", self._sprintweapon );
				self switchToWeapon( self._sprintweapon );

				self.sprinting = true;
				playbreathsound = true;
				wait 0.05;
			}
			// ha már sprintel
			else
			{
				cW = self getCurrentWeapon(); // current weapon
				pW = self getWeaponSlotWeapon( "primary" ); // current slot weapon

				if ( pW != self._sprintweapon ) // ha sprint közben fegyvert vált
				{
					maps\mp\_utility::deletePlacedEntity("weapon_" + self._sprintweapon);

					//self setWeaponSlotWeapon( cS, self._sprintweapon );
					//self switchToWeapon( self._sprintweapon );
					wait 0.05;
				}
				else if ( cW != self._sprintweapon )
				{
					self switchToWeapon( self._sprintweapon );
					wait 0.05;
				}
			}

			ammo = int( 100 * ( 1.0 - sprint ) );
			self setWeaponSlotAmmo( "primary", ammo );

			self._sprinttime--;
		}
		// sprint valamelyik feltétele nem teljesül
		else
		{
			// ha eddig sprintelt, de már nem akar
			if ( self.sprinting )
			{
				// visszadja az eredeti fegyvert
				self setWeaponSlotWeapon( "primary", _pW );
				self setWeaponSlotAmmo( "primary", _pW_ammo);
				self setWeaponSlotClipAmmo( "primary", _pW_clip);
				self switchToWeapon( _cW );

				recovertime = level.sprintrecovertime;
				recovertime = int( recovertime * sprint + 0.5 );

				self.sprinting = false;
				wait 0.05;
			}

			// sprint visszatöltése
			if ( self._sprinttime < level.sprinttime )
			{
				if ( recovertime > 0 )
				{
					recovertime--;
					if ( playbreathsound )
					{
						if ( ! randomInt( 6 ) )
							self playLocalSound("breathing_better");
						playbreathsound = false;
					}
				}
				else
				{
					self._sprinttime++;
				}
			}
		}
	}
}