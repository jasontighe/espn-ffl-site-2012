function add_linkage(doc)
{ 
	/// var package=prompt('Choose a package or live it blank','');
	
	package = '';
	
	if(package==null){
		alert('Cancelled');
	}
	
	if(package!='')
	{
		package+='.';
		//remove double points and spaces from package name and lower its case
		package=package.split('..').join('.').split(' ').join('').toLowerCase();
	}
	
	var library=doc.library;
	var items=library.items;
	var items_length=items.length;
	
	for( var h = 0; h < items_length; h++)
	{
		var item=items[h];
		if(item.itemType=='bitmap')
		{
			/// if(item.linkageExportForAS==false)
			
			if (true)
			{
				//extract class name from the item name
				
				/// var class_name=item.name.substr(item.name.lastIndexOf('/')+1).toLowerCase();
				
				var class_name=item.name.substr(item.name.lastIndexOf('/')+1);
				
				//remove extensions
				class_name=class_name.split('.jpg').join('');
				class_name=class_name.split('png').join('');
				class_name=class_name.split('.gif').join('');
				
				//force first letter to be uppercase				
				/// class_name=class_name.substr(0,1).toUpperCase()+class_name.substr(1); 
				
				//remove points and spaces
				class_name=class_name.split('.').join('').split(' ').join('');
				
				//sum and set it up
				item.linkageExportForAS=true;
				item.linkageExportInFirstFrame=true;
				item.linkageClassName=package+class_name;	
				item.linkageBaseClass='flash.display.BitmapData';
				
				fl.trace(item.linkageClassName);
			}
		}
	}
}

add_linkage(fl.getDocumentDOM());

fl.documents[0].save();

alert("Now press control-enter to create SWF file.");