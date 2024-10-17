-- update milestone names -------------------------------------------
update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_bigbluebuttonbn t on t.id = cm.`instance` and cm.module = 24
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_url t on t.id = cm.`instance` and cm.module = 21
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_resource t on t.id = cm.`instance` and cm.module = 18
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_quiz t on t.id = cm.`instance` and cm.module = 17
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_page t on t.id = cm.`instance` and cm.module = 16
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_label t on t.id = cm.`instance` and cm.module = 13
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_forum t on t.id = cm.`instance` and cm.module = 9
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_choice t on t.id = cm.`instance` and cm.module = 5
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_chat t on t.id = cm.`instance` and cm.module = 4
set j.name = t.name;

update mdl_tool_attestoodle_milestone j
	join mdl_course_modules cm on j.moduleid = cm.id 
	join mdl_assign t on t.id = cm.`instance` and cm.module = 1
set j.name = t.name;



