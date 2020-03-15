cvarDef(type, varname, vardefault, min, max)
{
	if (!isDefined(level.cvars))
		level.cvars = [];
	level.cvars[varname] = type;

	switch(type)
	{
		case "int":
			if(getCvar(varname) == "")
				definition = vardefault;
			else
				definition = getCvarInt(varname);
		break;
		case "float":
			if(getCvar(varname) == "")
				definition = vardefault;
			else
				definition = getCvarFloat(varname);
		break;
		case "string":
		default:
			if(getCvar(varname) == "")
				definition = vardefault;
			else
				definition = getCvar(varname);
		break;
	}

	if((type == "int" || type == "float") && definition < min)
		definition = min;

	if((type == "int" || type == "float") && definition > max)
		definition = max;

	setCvar( varname, definition );
	return definition;
}

printToScreen(origin, print, color)
{
	for (;;)
	{
		/#
			print3d(origin, print, color, 1, 1, 1);
		#/

		wait 0.05;
	}
}

drawLink(start, end, color)
{
	for (;;)
	{
		/#
			line(start, end, color, true);
		#/

		wait 0.05;
	}
}

is_true(check)
{
	return(isDefined(check) && check);
}

is_false(check)
{
	return(isDefined(check) && !check);
}

timer(note, time)
{
	self endon(note);
	wait time;
	self notify(note);
}

join(separator, array)
{
	tmp = "";
	copyArr = array;
	for (i = 0; i < copyArr.size; i++)
	{
		if (isDefined(copyArr[i]))
			tmp += copyArr[i];
			
		if (i < copyArr.size - 1)
			tmp += separator;
	}

	return tmp;
}

getTargetPlayers()
{
	result = [];
	players = getEntArray("player", "classname");

	for (i = 0; i < players.size; i++)
	{
		if (players[i].sessionstate != "playing" || players[i].invisibilities.size > 0)
			continue;
		
		result[result.size] = players[i];
	}

	return result;
}

getPlayingPlayers()
{
	result = [];
	players = getEntArray("player", "classname");

	for (i = 0; i < players.size; i++)
	{
		if (players[i].sessionstate == "playing")
			result[result.size] = players[i];
	}

	return result;
}

getAllPlayers()
{
	return getEntArray("player", "classname");
}

getPlayingPlayersCount()
{
	players = getPlayingPlayers();
	return players.size;
}

spawnModel(modelname, origin, angles)
{
	entity = spawn("script_model", origin);
	entity.angles = angles;
	entity setModel( modelname );
	return entity;
}

plantOrigin(origin)
{
	plant = bulletTrace(origin, origin - (0,0,128), false, undefined);

	if (plant["fraction"] != 1)
		return plant["position"];

	return origin;
}

plantOrigin2(origin, length)
{
	plant = bulletTrace(origin, origin - (0, 0, length), false, undefined);

	if (plant["fraction"] == 1)
		return undefined;

	return plant["position"];
}

vectorScale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

setHealth( health )
{
	self setNormalHealth( health / self.maxhealth );
	self notify("update_healthbar");
}

// Wait for any string
waittill_any(string1, string2, string3, string4, string5)
{
	assert( IsDefined( string1 ) );
	
	if ( IsDefined( string2 ) )
		self endon( string2 );

	if ( IsDefined( string3 ) )
		self endon( string3 );

	if ( IsDefined( string4 ) )
		self endon( string4 );

	if ( IsDefined( string5 ) )
		self endon( string5 );
	
	self waittill( string1 );
}

pow(value, power)
{
	if (! power)
		return 1;

	multiplier = value;
	for (i = 1; i < power; i++)
		value *= multiplier;

	return value;
}

sqrt(input)
{
	a = input;
	x = 1;

	for (i = 0; i < input; i++)
	{
		x = 0.5 * (x + a / x);
	}

	return x;
	/*if (input <= 0)
		return 0;

	output = 0;
	for (i = 0.001; i <= 10000000; i *= 10)
	{
		_i = 1 / i;
		while (output * output <= input)
			output += _i;

		if (output * output > input)
			output -= _i;
	}

	return output;*/
}

angle_dif( angles1, angles2 )
{
	vec1 = anglesToForward(angles1);
	vec2 = anglesToForward(angles2);

	return vectorAngle(vec1, vec2);
}

vectorAngle(v1, v2)
{
	dot = vectorDot(v1, v2);
	if (dot >= 1)
		return 0;
	else if (dot <= -1)
		return 180;
	return acos(dot);
}

vector_compare(vec1, vec2, diff)
{
	return (abs(vec1[0] - vec2[0]) < diff) && (abs(vec1[1] - vec2[1]) < diff) && (abs(vec1[2] - vec2[2]) < diff);
}

abs( value )
{
	if (value < 0)
		value *= -1;

	return value;
}

min(a, b)
{
	if (a < b)
		return a;
	else
		return b;
}

max(a, b)
{
	if (a > b)
		return a;
	else
		return b;
}

clamp(value, min, max)
{
	if (value < min)
		return min;
	else if (value > max)
		return max;
	else
		return value;
}

random_percentage(percent)
{
	percent = clamp(percent, 0, 100);

	if (randomFloat(100) + 1 <= percent)
		return true;
	else
		return false;
}

print_r(array)
{
	for (i = 0; i < array.size; i++)
	{
		iPrintln("[" + i + "] => " + array[i]);
	}
}

array(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
{
	array = [];
	if ( IsDefined( a ) ) array[ 0] = a; else return array;
	if ( IsDefined( b ) ) array[ 1] = b; else return array;
	if ( IsDefined( c ) ) array[ 2] = c; else return array;
	if ( IsDefined( d ) ) array[ 3] = d; else return array;
	if ( IsDefined( e ) ) array[ 4] = e; else return array;
	if ( IsDefined( f ) ) array[ 5] = f; else return array;
	if ( IsDefined( g ) ) array[ 6] = g; else return array;
	if ( IsDefined( h ) ) array[ 7] = h; else return array;
	if ( IsDefined( i ) ) array[ 8] = i; else return array;
	if ( IsDefined( j ) ) array[ 9] = j; else return array;
	if ( IsDefined( k ) ) array[10] = k; else return array;
	if ( IsDefined( l ) ) array[11] = l; else return array;
	if ( IsDefined( m ) ) array[12] = m; else return array;
	if ( IsDefined( n ) ) array[13] = n; else return array;
	if ( IsDefined( o ) ) array[14] = o; else return array;
	if ( IsDefined( p ) ) array[15] = p; else return array;
	if ( IsDefined( q ) ) array[16] = q; else return array;
	if ( IsDefined( r ) ) array[17] = r; else return array;
	if ( IsDefined( s ) ) array[18] = s; else return array;
	if ( IsDefined( t ) ) array[19] = t; else return array;
	if ( IsDefined( u ) ) array[20] = u; else return array;
	if ( IsDefined( v ) ) array[21] = v; else return array;
	if ( IsDefined( w ) ) array[22] = w; else return array;
	if ( IsDefined( x ) ) array[23] = x; else return array;
	if ( IsDefined( y ) ) array[24] = y; else return array;
	if ( IsDefined( z ) ) array[25] = z;
	return array;
}

is_in_array(aeCollection, eFindee)
{
	if (! isDefined(aeCollection))
		return (false);

	for(i = 0; i < aeCollection.size; i++)
	{
		if(aeCollection[i] == eFindee)
			return (true);
	}

	return (false);
}

add_to_array(array, item, allow_dupes)
{
	if (! isDefined(item))
		return array;

	if (! isDefined(allow_dupes))
		allow_dupes = true;

	if (! isDefined(array))
		array[ 0 ] = item;
	else if (allow_dupes || ! is_in_array(array, item))
		array[ array.size ] = item;

	return array; 
}

array_add(array, item)
{
	array[ array.size ] = item;
	return array; 
}

array_insert(array, item, index)
{
	if (index == array.size)
	{
		temp = array;
		temp[temp.size] = item;
		return temp;
	}

	temp = [];
	offset = 0;
	for (i = 0; i < array.size; i++)
	{
		if (i == index)
		{
			temp[i] = item;
			offset = 1;
		}
		temp[i + offset] = array[i];
	}

	return temp;
}

array_remove(array, item)
{
	newarray = [];
	for (i = 0; i < array.size; i++)
	{
		if(array[i] != item)
			newarray[newarray.size] = array[i];
	}
	return newarray;
}

array_removeAt(array, index)
{
	newarray = [];
	for (i = 0; i < array.size; i++)
	{
		if(i != index)
			newarray[newarray.size] = array[i];
	}
	return newarray;
}

array_removeUndefined(array)
{
	newArray = [];
	for (i = 0; i < array.size; i++)
	{
		if (! isDefined(array[i]))
		{
			continue;
		}
		newArray[newArray.size] = array[i];
	}

	return newArray;
}

array_randomItem(array)
{
	if (!array.size)
		return undefined;
	
	return array[randomInt(array.size)];
}

array_sort(array)
{
	temp = array;

	for (i = 0; i < temp.size - 1; i++)
	{
		for (j = i + 1; j < temp.size; j++)
		{
			if (temp[i] > temp[j])
			{
				var = temp[i];
				temp[i] = temp[j];
				temp[j] = var;
			}
		}
	}

	return temp;
}

array_shuffle(array)
{
	newArray = array;

	for (i = newArray.size - 1; i > 0; i--)
	{
		j = randomInt(i + 1);
		// swap
		temp = newArray[i];
		newArray[i] = newArray[j];
		newArray[j] = temp;
	}

	return newArray;
}

array_indexOfMinNumber(array)
{
	n = undefined;
	for (i = 0; i < array.size; i++)
		if (!isDefined(n) || array[i] < array[n])
			n = i;
	return n;
}

randall_precacheString(string)
{
	if (! isDefined(level.precachestring))
		level.precachestring = [];

	if (is_in_array(level.precachestring, string))
		return;

	level.precachestring = array_add(level.precachestring, string);

	precacheString(string);
}

randall_precacheShader(shader)
{
	if (! isDefined(level.precacheshader))
		level.precacheshader = [];

	if (is_in_array(level.precacheshader, shader))
		return;

	level.precacheshader = array_add(level.precacheshader, shader);

	precacheShader(shader);
}

randall_precacheItem(item)
{
	if (! isDefined(level.precacheitem))
		level.precacheitem = [];

	if (is_in_array(level.precacheitem, item))
		return;

	level.precacheitem = array_add(level.precacheitem, item);

	precacheItem(item);
}

randall_precacheStatusIcon(statusicon)
{
	if (! isDefined(level.precachestatusicon))
		level.precachestatusicon = [];

	if (is_in_array(level.precachestatusicon, statusicon))
		return;

	level.precachestatusicon = array_add(level.precachestatusicon, statusicon);

	precacheStatusIcon(statusicon);
}

randall_precacheHeadIcon(headicon)
{
	if (! isDefined(level.precacheheadicon))
		level.precacheheadicon = [];

	if (is_in_array(level.precacheheadicon, headicon))
		return;

	level.precacheheadicon = array_add(level.precacheheadicon, headicon);

	precacheHeadIcon(headicon);
}

randall_precacheMenu(menu)
{
	if (! isDefined(level.precachemenu))
		level.precachemenu = [];

	if (is_in_array(level.precachemenu, menu))
		return;

	level.precachemenu = array_add(level.precachemenu, menu);

	precacheMenu(menu);
}

randall_precacheModel(model)
{
	if (! isDefined(level.precachemodel))
		level.precachemodel = [];

	if (is_in_array(level.precachemodel, model))
		return;

	level.precachemodel = array_add(level.precachemodel, model);

	precacheModel(model);
}

randall_precacheFX(name, fx_path)
{
	if (! isDefined(level.FXs))
		level.FXs = [];

	if (! isDefined(level.wasFX))
		level.wasFX = [];

	if (is_in_array(level.wasFX, fx_path))
		return;

	level.wasFX = array_add(level.wasFX, fx_path);
	level.FXs[ name ] = loadFX( fx_path );
}

randall_precacheShellShock(alias)
{
	if (! isDefined(level.precacheshellshock))
		level.precacheshellshock = [];

	if (is_in_array(level.precacheshellshock, alias))
		return;

	level.precacheshellshock = array_add(level.precacheshellshock, alias);

	precacheShellShock(alias);
}

getCurrentWeaponSlot()
{
	current = self getCurrentWeapon();
	weapon1 = self getWeaponSlotWeapon("primary");
	weapon2 = self getWeaponSlotWeapon("primaryb");

	if (current == weapon1)
		currentslot = "primary";
	else
	{
		//assert(current == weapon2);
		currentslot = "primaryb";
	}
	return currentslot;
}

getTagOrigin(tag)
{
	if ( ! isDefined(self.locationMarkers) )
	{
		return self.origin;
	}

	if ( ! isDefined(self.locationMarkers[ tag ]) )
	{
		setTag(tag);
	}

	marker = self.locationMarkers[ tag ];
	return marker.origin;
}

setTag(tag)
{
	if ( ! isDefined(self.locationMarkers) )
		self.locationMarkers = [];

	wait 0.01;

	tagMarker = spawn("script_origin", (0,0,0));
	tagMarker.angles = (0,0,0);
	tagMarker linkTo(self, tag, (0,0,0), (0,0,0));

	self.locationMarkers[ tag ] = tagMarker;
}

deleteTag(tag)
{
	if ( ! isDefined(self.locationMarkers) )
		return;

	if ( ! isDefined(self.locationMarkers[ tag ]) )
		return;

	marker = self.locationMarkers[ tag ];
	self.locationMarkers[ tag ] = undefined;
	marker delete();
}

parseMaps(string)
{
    arr = strTok(string, " ");
    maps = [];
    for (i = 0; i < arr.size; i++)
    {
        if (arr[i] == "map" && i + 1 < arr.size)
        {
            i++;
            maps[maps.size] = arr[i];
        }
    }

    return maps;
}