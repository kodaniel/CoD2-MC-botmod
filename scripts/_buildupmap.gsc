#include scripts\_utils;

buildWaypoints()
{
	level.waypoints = getEntArray("node_pathnode", "classname");

	if ( ! level.waypoints.size )
		return false;

	for (i = 0; i < level.waypoints.size; i++)
	{
		level.waypoints[i].id				= i;
		level.waypoints[i].openListID		= undefined;
		level.waypoints[i].closedListID		= undefined;
		level.waypoints[i].parentNode		= undefined;
		level.waypoints[i].g				= 0;
		level.waypoints[i].h				= 0;
		level.waypoints[i].f				= 0;
		level.waypoints[i].parent			= [];

		for ( j = 0; j < level.waypoints.size; j++ )
		{
			if ( i != j && sightTracePassed( level.waypoints[i].origin + level.offset, level.waypoints[j].origin + level.offset, false, undefined ) )
				level.waypoints[i].parent[level.waypoints[i].parent.size] = j;
		}

		/#
			thread printToScreen(level.waypoints[i].origin, level.waypoints[i].id, (1,0,0));
		#/

		if ( ! level.waypoints[i].parent.size )
			println( "^1Error: Node " + level.waypoints[i].id + " is lonely^7");
	}

	return true;
}

buildEdges()
{
	edges = getEntArray("node_scripted", "classname");

	level.edges = [];
	for (i = 0; i < edges.size; i++)
	{
		if ( ! isDefined( edges[i].target ) ) // node párját nem teszi a tömbbe
			continue;

		count = level.edges.size;

		level.edges[count] = edges[i];
		level.edges[count].id = count + "A";

		pair = getEdgeID( edges, level.edges[count].target );
		level.edges[count].pair = edges[pair];
		level.edges[count].pair.id = count + "B";

		/#
			thread printToScreen(level.edges[count].origin, level.edges[count].id, (0,0,1));
			thread printToScreen(level.edges[count].pair.origin, level.edges[count].pair.id, (0,0,1));
			thread drawLink(level.edges[count].origin, level.edges[count].pair.origin, (0,0,1));
		#/
	}
}

buildHitbox()
{
	hitboxtype = [];
	hitboxtype[0]	= spawnStruct();
	hitboxtype[0].n	= "default";
	hitboxtype[0].e	= getEntArray("hitbox", "targetname");

	level.hitbox = [];

	for ( i = 0; i < hitboxtype.size; i++ )
	{
		level.hitbox[ hitboxtype[ i ].n ] = [];

		for ( j = 0; j < hitboxtype[ i ].e.size; j++ )
		{
			count = level.hitbox[hitboxtype[ i ].n].size;

			level.hitbox[hitboxtype[ i ].n][count]			= hitboxtype[ i ].e[ j ];
			level.hitbox[hitboxtype[ i ].n][count].trig		= getEnt( level.hitbox[hitboxtype[ i ].n][count].target, "targetname" );
			level.hitbox[hitboxtype[ i ].n][count].trig		enableLinkTo();
			level.hitbox[hitboxtype[ i ].n][count].trig		linkTo( level.hitbox[hitboxtype[ i ].n][count] );
			level.hitbox[hitboxtype[ i ].n][count].use		= false;
			level.hitbox[hitboxtype[ i ].n][count].origin	= (0,0,10000);
		}
	}
}

buildPaths()
{
	level.paths = [];

	for ( start = 0; start < level.waypoints.size; start++ ) // from all startNode
	{
		level.paths[start] = [];

		for ( end = 0; end < level.waypoints.size; end++ ) // to all endNode
		{
			if ( start == end )
				continue;

			path = generatePath( level.waypoints[start], level.waypoints[end] ); // generate the path between start and end

			if ( ! isDefined( path ) || ! path.size )
			{
				println(" ^1Error: no path found: " + start + " -> " + end + "^7\n");
				return false;
			}

			dist = 0;
			for (i = 0; i < path.size - 1; i++)
				dist += distanceSquared( path[ i ].origin, path[ i + 1 ].origin );

			level.paths[start][end]			= spawnStruct();
			level.paths[start][end].name	= ( start + "," + end );
			level.paths[start][end].path	= path;
			level.paths[start][end].dist	= dist;
		}
	}

	return true;
}

generatePath(destNode, startNode)
{
	level.openList = [];
	level.closedList = [];
	foundPath = false;
	pathNodes = [];
	
	startNode.g = 0;
	startNode.h = getHValue ( startNode, destNode );
	startNode.f = startNode.g + startNode.h;

	addToClosedList (startNode);

	curNode = startNode;

	while( 1 )
	{
		for( i = 0 ; i < level.waypoints[curNode.id].parent.size ; i++ )
		{
			parent = level.waypoints[level.waypoints[curNode.id].parent[i]];
			checkNode = level.waypoints[parent.id];

			if(is_in_array (level.closedList, checkNode))
				continue;

			if(!is_in_array (level.openList, checkNode))
			{
				addToOpenList (checkNode);
				checkNode.parentNode = curNode;
				checkNode.g = getGValue ( checkNode, curNode );
				checkNode.h = getHValue ( checkNode, curNode );
				checkNode.f = checkNode.g + checkNode.h;

				if (checkNode.id == destNode.id)
					foundPath = true;
			}
			else
			{
				if(checkNode.g < getGValue ( curNode, checkNode ))
					continue;
				
				checkNode.parentNode = curNode;
				checkNode.g = getGValue ( checkNode, curNode );
				checkNode.f = checkNode.g + checkNode.h;
			}
		}
		
		if(foundPath)
			break;
			
		addToClosedList (curNode);
		
		bestNode = level.openList[0];
		for(i = 1; i < level.openList.size; i++)
		{
			if (level.openList[i].f > bestNode.f)
				continue;

			bestNode = level.openList[i];
		}
		
		if(!isdefined (bestNode))
		{
			return pathNodes;
		}

		addToClosedList (bestNode);
		curNode = bestNode;
	}

	assert (isdefined (destNode.parentNode));

	curNode = destNode;

	while( curNode.id != startNode.id )
	{
		pathNodes[pathNodes.size] = curNode;
		curNode = curNode.parentNode;
	}
	pathNodes[pathNodes.size] = curNode;
	
	return pathNodes;
}

addToOpenList(node)
{
	node.openListID = level.openList.size;
	level.openList[level.openList.size] = node;
	node.closedListID = undefined;
}

addToClosedList(node)
{
	if (isdefined (node.closedListID))
		return;
	
	node.closedListID = level.closedList.size;
	level.closedList[level.closedList.size] = node;

	if (!is_in_array (level.openList, node))
		return;

	level.openList[node.openListID] = level.openList[level.openList.size - 1];
	level.openList[node.openListID].openListID = node.openListID;
	level.openList[level.openList.size - 1] = undefined;
	node.openListID = undefined;
}

getHValue(node1, node2)
{
	return (distance ( node1.origin, node2.origin ));
}

getGValue(node1, node2)
{
	return (node1.parentNode.g + distance ( node1.origin, node2.origin ));
}

getEdgeID( array, targetname )
{
	for (i = 0; i < array.size; i++)
	{
		if ( ! isDefined(array[i].targetname) )
			continue;

		if ( array[i].targetname == targetname )
			return i;
	}
}