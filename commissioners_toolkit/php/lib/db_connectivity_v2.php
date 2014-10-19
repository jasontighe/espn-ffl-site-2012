<?
/**
 * database connectivity
 *
 **/
class DB extends DB_Sql {

  var $Host;
  var $Database;
  var $User;
  var $Password;
  var $Logger;
  var $CriticalErrorManager;
  
  function DB(){
	global $Logger, $CriticalErrorManager;

    $this->Host = DB_HOST;
    $this->Database = DB_NAME;
    $this->User = DB_USER;
    $this->Password = DB_PASS;

	$this->Logger = $Logger;
	$this->CriticalErrorManager = $CriticalErrorManager;
  }
  
}

class DB_Sql {
  
  /* public: connection parameters */
  var $Host;
  var $Database;
  var $User;
  var $Password;
  var $Logger;
  var $CriticalErrorManager;

  /* public: configuration parameters */
  var $Auto_Free     = 0;     ## Set to 1 for automatic mysql_free_result()
  var $Debug         = 0;     ## Set to 1 for debugging messages.
  var $Halt_On_Error = "no"; ## "yes" (halt with message), "no" (ignore errors quietly), "report" (ignore errror, but spit a warning)
  var $Seq_Table     = "db_sequence";

  /* public: result array and current row number */
  var $Record   = array();
  var $Row;

  /* public: current error number and error text */
  var $Errno    = 0;
  var $Error    = "";

  /* public: this is an api revision, not a CVS revision. */
  var $type     = "mysql";
  var $revision = "1.2";

  /* private: link and query handles */
  var $Link_ID  = 0;
  var $Query_ID = 0;
  


  /* public: constructor */
  function DB_Sql($query = "") {
    //    $this->fileIO = new fileIO;
    $this->query($query); 
//    $this->
  }

  /* public: some trivial reporting */
  function link_id() {    
    return $this->Link_ID;
  }

  function query_id() {
    return $this->Query_ID;
  }

  /* public: connection management */
  function connect($Database = "", $Host = "", $User = "", $Password = "") {
    /* Handle defaults */
    if ("" == $Database)
      $Database = $this->Database;
    if ("" == $Host)
      $Host     = $this->Host;
    if ("" == $User)
      $User     = $this->User;
    if ("" == $Password)
      $Password = $this->Password;
      
    /* establish connection, select database */
    if ( 0 == $this->Link_ID ) {
    
      $this->Link_ID=mysql_connect($Host, $User, $Password);
      if (!$this->Link_ID) {
        $this->halt("connect($Host, $User, \$Password) failed.");
        return 0;
      }

      if (!@mysql_select_db($Database,$this->Link_ID)) {
        $this->halt("cannot use database ".$this->Database);
        return 0;
      }
    }
    
    return $this->Link_ID;
  }

  function free() {
	//	This function (@mysql_free_result) is only needed for
	//	memory conservation on big queries.  This will be 
	//	automatically handled when the script terminates
      //@mysql_free_result($this->Query_ID);
      $this->Query_ID = 0;
  }  

  function escape($str){
    $this->connect();    
    return mysql_real_escape_string($str, $this->link_id());
  }

  /* public: perform a query */
  function query($Query_String) {

    /* No empty queries, please, since PHP4 chokes on them. */
    if ($Query_String == "")
      /* The empty query string is passed on from the constructor,
       * when calling the class without a query, e.g. in situations
       * like these: '$db = new DB_Sql_Subclass;'
       */
      return 0;

    if (!$this->connect()) {
      return 0; /* we already complained in connect() about that. */
    };

    # New query, discard previous result.
    if ($this->Query_ID) {
	$this->free();
    }

    if ($this->Debug)
      printf("Debug: query = %s<br>\n", $Query_String);
    //   $this->query_time_start = 
 
    if(@ereg(";", $Query_String)){
      $query_array = explode(";", $Query_String);      
    }
    
    if(isset($query_array)){
      foreach($query_array as $query){
	$this->Query_ID = @mysql_query($query,$this->Link_ID);    
	$this->Row   = 0;
	$this->Errno = mysql_errno();
	$this->Error = mysql_error();
	if (!$this->Query_ID) {
	  $this->halt("Invalid SQL: ".$query);
	}
      }
    } else {
      $this->Query_ID = @mysql_query($Query_String,$this->Link_ID);
      $this->Row   = 0;
      $this->Errno = mysql_errno();
      $this->Error = mysql_error();
      if (!$this->Query_ID) {
	$this->halt("Invalid SQL: ".$Query_String);
      }
    }


    # Will return nada if it fails. That's fine.
    return $this->Query_ID;
  }

  function last_id(){
    return @mysql_insert_id($this->Link_ID);
  }

  /* public: walk result set */
  function next_record($assoc = null) {
    if (!$this->Query_ID) {
      $this->halt("next_record called with no query pending.");
      return 0;
    }
	
	if ($assoc){
    	$this->Record = @mysql_fetch_array($this->Query_ID, MYSQL_ASSOC);
    }else{
    	$this->Record = @mysql_fetch_array($this->Query_ID);
    }
    $this->Row   += 1;
    $this->Errno  = mysql_errno();
    $this->Error  = mysql_error();

    $stat = is_array($this->Record);
    if (!$stat && $this->Auto_Free) {
      $this->free();
    }
    return $stat;
  }

  function num_rows() {
    return @mysql_num_rows($this->Query_ID);
  }

  function aff_rows() {
    return @mysql_affected_rows($this->Link_ID);
  }

  function num_fields() {
    return @mysql_num_fields($this->Query_ID);
  }

  /* public: shorthand notation */
  function nf() {
    return $this->num_rows();
  }

  /* public: shorthand notation */
  function noff() {
    return $this->aff_rows();
  }

  function f($Name) {
    return $this->Record[$Name];
  }

  function fr() {
    return $this->Record;
  }
  
  function getResultArray($fields) {
  	if($this->nf() >= 1) {
  		
  		//iterator
  		$i = 0;
  		
  		while($this->next_record()) {

  			foreach($fields as $field) {
  				$results[$i][$field] = $this->f($field);

  			}
$i++;
  		}
  		return $results;
  		
  	} else {
  		//error
  		return -1;
  	}
  }


  /* private: error handling */
  function halt($msg) {
    $this->Error = @mysql_error($this->Link_ID);
//    $this->Errno = @mysql_errno($this->Link_ID);

//	$this->CriticalErrorManager->handleError(false, $this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Invalid SQL: " . addslashes($this->Error)));

//    if ($this->Halt_On_Error == "no")
//      return;


//    if ($this->Halt_On_Error != "report")
//      die("Session halted.");
  }

}
?>
