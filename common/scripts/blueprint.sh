
#!/bin/bash

# The functions below assume that there is a file called blueprint 
# in the current folder. And these functions return various values 
# in that blueprint file 

function get_author {
	a=$(grep -m 1 author blueprint | sed -e 's/author:\s*//')
	echo $a
}

function get_title { 
	t=$(grep -m 1 title blueprint | sed -e 's/title:\s*//')
	echo $t
}

function get_page_breaks { 
	pgb=$(grep -m 1 pageBreaks blueprint | sed -e 's/pageBreaks:\s*//')
	echo $pgb
}

function get_versions { 
	v=$(grep -m 1 versions blueprint | sed -e 's/versions:\s*//')
	echo $v
}

function get_response_ids { 
	ids=$(grep -m 1 responses blueprint | sed -e 's/responses:\s*//')
	echo $ids
}

function get_import_folders { 
	i=$(grep import blueprint | sed -e 's/import:\s*//')
	echo $i
}

function get_mode { 
	m=$(grep mode blueprint | sed -e 's/mode:\s*//')
	echo $m
}
