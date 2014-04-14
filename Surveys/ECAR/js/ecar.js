Ext.ns("MyApp");

MyApp.MainPanel = new MyApp.Form({
	createWest: function() {
		var tb = new Ext.form.TextField({
			width: 200,
			emptyText: 'Find a node',
			listeners: {
				render: function(f) {
					f.el.on('keydown', filterTree, f, { buffer: 350 });
				}
			}
		});
		
		


		var tree = new MyApp.Tree({
			region: 'west',
			title: 'Table of Content',
			refreshButton: true,
			collapsible: true,
			 resizeTabs:true,
			 enableTabScroll:true,
			split: true,
			useArrows: true,
			singleClickExpand:true,
        autoScroll: true,
        animate: true,
        enableDD: true,
		defaults: {autoScroll:true},
        containerScroll: true,
			width: 400,
			minSize: 175,
			maxSize: 500,
			margins: '5 0 5 5',
			cmargins: '0 5 5 5',
			tbar: [tb]
		});
				var json =
		[
		{ "text": "Survey Overview", "id": 100, "expanded": true, "leaf": false, "cls": "folder", "children": [
		{ "text": "Description", "id": "h1000", "leaf": true, "cls": "folder", "url": "Description/index.htm", "html": "Amit, Amit"
		},{ "text": "IR Preview", "id": "h1002", "expanded": false, "leaf": false, "cls": "folder", "children": [
		{ "text": "2008", "id": "2008IR", "expanded": false, "leaf": false, "cls": "folder", "children": [
		{ "text": "Daytona Beach", "id": "2008IRDB", "leaf": true, "cls": "folder", "url": "Report/2008IRDB.htm", "html": "Amit, Amit"
		},{ "text": "Prescott", "id": "2008IRPC", "leaf": true, "cls": "folder", "url": "Report/2008IRPC.htm", "html": "Amit, Amit"
		},{ "text": "Worldwide", "id": "2008IRWW", "leaf": true, "cls": "folder", "url": "Report/2008IRWW.htm", "html": "Amit, Amit"
		}]
		},{ "text": "2009", "id": "2009IR", "expanded": false, "leaf": false, "cls": "folder",  "children": [
		{ "text": "Daytona Beach", "id": "2009IRDB", "leaf": true, "cls": "folder", "url": "Report/2009IRDB.htm", "html": "Amit, Amit"
		},{ "text": "Prescott", "id": "2009IRPC", "leaf": true, "cls": "folder", "url": "Report/2009IRPC.htm", "html": "Amit, Amit"
		},{ "text": "Worldwide", "id": "2009IRWW", "leaf": true, "cls": "folder", "url": "Report/2009IRWW.htm", "html": "Amit, Amit"
		}]
		},{ "text": "2010", "id": "2010IR", "expanded": false, "leaf": false, "cls": "folder",  "children": [
		{ "text": "Daytona Beach", "id": "2010IRDB", "leaf": true, "cls": "folder", "url": "Report/2010IRDB.htm", "html": "Amit, Amit"
		},{ "text": "Prescott", "id": "2010IRPC", "leaf": true, "cls": "folder", "url": "Report/2010IRPC.htm", "html": "Amit, Amit"
		},{ "text": "Worldwide", "id": "2010IRWW", "leaf": true, "cls": "folder", "url": "Report/2010IRWW.htm", "html": "Amit, Amit"
		}]
		}]
		
		}]
		
		},
		{ "text": "Full Report", "id": 2000, "cls": "folder", "children": [
		
		{ "text": "Overview", "id": "s1000", "leaf": true, "cls": "folder", "url": "Report/index.htm", "html": "Amit, Amit"
		}, { "text": "Student Ownership of Technology", "id": 103, "expanded": false, "leaf": false, "cls": "folder", "children": [
		{ "text": "How old is your Personal desktop computer", "id": "q3a", "leaf": true, "cls": "folder", "url": "Report/q3a.htm", "html": "Amit, Amit"
		}, { "text": "How old is your Personal full-sized laptop computer", "id": "q3b", "leaf": true, "cls": "folder", "url": "Report/q3b.htm"
},{ "text": "How old is your personal small, lightweight netbook computer", "id": "q3c", "leaf": true, "cls": "folder", "url": "Report/q3c.htm"
},{ "text": "How old is your personal dedicated e-book reader (Amazon Kindle, Sony Reader etc)", "id": "q3d", "leaf": true, "cls": "folder", "url": "Report/q3d.htm"
},{ "text": "Do you own a cell phone that is capable of accessing the internet", "id": "q7", "leaf": true, "cls": "folder", "url": "Report/q7.htm"
}]
		
		},{"text": "Student Use of Technology", "id": 101, "leaf": false, "cls": "folder", "children": [
		{ "text": "Which of the following describes you", "id": "q22", "leaf": true, "cls": "folder", "url": "Report/q22.htm"
		}, { "text": "I like to learn through", "id": "q23", "leaf": false, "cls": "folder", "children": [
		{"text": "Text-based conversations over e-mail, instant messaging, and text messaging", "id": "q23a", "leaf": true, "cls": "folder", "url": "Report/q23a.htm"
		},{"text": "Programs I can control, such as video games, simulations, etc.", "id": "q23b", "leaf": true, "cls": "folder", "url": "Report/q23b.htm"
		},{"text": "Contributing to websites, blogs, wikis, etc.", "id": "q23c", "leaf": true, "cls": "folder", "url": "Report/q23c.htm"
		},{"text": "Running Internet Searches", "id": "q23d", "leaf": true, "cls": "folder", "url": "Report/q23d.htm"
		},{"text": "Listening to audio or watching video content", "id": "q23e", "leaf": true, "cls": "folder", "url": "Report/q23e.htm"
		},{"text": "Creating audio or video content", "id": "q23f", "leaf": true, "cls": "folder", "url": "Report/q23f.htm"
		}]
		}, { "text": "How many hours each week do you spend actively doing Internet activities for school, work or recreation", "id": "q4", "leaf": true, "cls": "folder", "url": "Report/q4.htm"
		}, { "text": "How often do you do the following (for school, work or recreation)", "id": "q5", "leaf": false, "cls": "folder", "children": [
		{"text": "Instant message", "id": "q5a", "leaf": true, "cls": "folder", "url": "Report/q5a.htm"
		},{"text": "Text message", "id": "q5b", "leaf": true, "cls": "folder", "url": "Report/q5b.htm"
		},{"text": "Use the college/university library website", "id": "q5c", "leaf": true, "cls": "folder", "url": "Report/q5c.htm"
		},{"text": "Spreadsheets (Excel etc.)", "id": "q5d", "leaf": true, "cls": "folder", "url": "Report/q5d.htm"
		},{"text": "Presentation software (PowerPoint, etc.)", "id": "q5e", "leaf": true, "cls": "folder", "url": "Report/q5e.htm"
		},{"text": "Graphics software (Photoshop, Flash, etc.)", "id": "q5f", "leaf": true, "cls": "folder", "url": "Report/q5f.htm"
		},{"text": "Audio-creation software (Audacity, GarageBand, etc.)", "id": "q5g", "leaf": true, "cls": "folder", "url": "Report/q5g.htm"
		},{"text": "Video-creation software (Moviemaker, iMovie, etc.)", "id": "q5h", "leaf": true, "cls": "folder", "url": "Report/q5h.htm"
		},{"text": "Online multi-user computer games (World of warcraft, Runescape, Lineage, poker, etc.)", "id": "q5i", "leaf": true, "cls": "folder", "url": "Report/q5i.htm"
		},{"text": "Online virtual worlds (Second Life, Forterra, etc.)", "id": "q5j", "leaf": true, "cls": "folder", "url": "Report/q5j.htm"
		},{"text": "Social bookmarking/tagging (Delicious, Digg, Newsvine, Twine, etc.)", "id": "q5k", "leaf": true, "cls": "folder", "url": "Report/q5k.htm"
		},{"text": "Voice over Internet Protocol (VOIP) from your computer (Skype, etc.)", "id": "q5l", "leaf": true, "cls": "folder", "url": "Report/q5l.htm"
		},{"text": "Follow or update micro-blogs (Twitter, etc.)", "id": "q5m", "leaf": true, "cls": "folder", "url": "Report/q5m.htm"
		}]
		}, { "text": "How often do you contribute content to the following for school, work, or recreation?", "id": "q6tyt", "leaf": false, "cls": "folder", "children": [
		{"text": "Wikis (Wikipedia, course wiki, etc.)", "id": "q6a", "leaf": true, "cls": "folder", "url": "Report/q6a.htm"
		},{"text": "Blogs", "id": "q6b", "leaf": true, "cls": "folder", "url": "Report/q6b.htm"
		},{"text": "Videos to video-sharing websites (YouTube, etc.)", "id": "q6c", "leaf": true, "cls": "folder", "url": "Report/q6c.htm"
		}]
		},
		{ "text": "What is your skill level for the following", "id": "q11", "leaf": false, "cls": "folder", "children": [
		{"text": "Using the college/university library website", "id": "q11a", "leaf": true, "cls": "folder", "url": "Report/q11a.htm"
		},{"text": "Spreadsheets (Excel, etc.)", "id": "q11b", "leaf": true, "cls": "folder", "url": "Report/q11b.htm"
		},{"text": "Presentation software (PowerPoint, etc.)", "id": "q11c", "leaf": true, "cls": "folder", "url": "Report/q11c.htm"
		},{"text": "Graphics Software", "id": "q11d", "leaf": true, "cls": "folder", "url": "Report/q11d.htm"
		},{"text": "Computer Maintenance (software updates, security, etc.)", "id": "q11e", "leaf": true, "cls": "folder", "url": "Report/q11e.htm"
		},{"text": "Using the Internet to effectively and efficently search for information", "id": "q11f", "leaf": true, "cls": "folder", "url": "Report/q11f.htm"
		},{"text": "Evaluating the reliability and credibility of online sources of information", "id": "q11g", "leaf": true, "cls": "folder", "url": "Report/q11g.htm"
		},{"text": "Understanding the ethical/legal issues surrounding the access to and use of digital information", "id": "q11h", "leaf": true, "cls": "folder", "url": "Report/q11h.htm"
		}]
		}]
		}
		,{"text": "Information Technology in Courses", "id": 102, "leaf": false, "cls": "folder", "children": [
		{ "text": "It would benefit students if my institution required students to take at least one entirely online course", "id": "itic1", "leaf": true, "cls": "folder", "url": "Report/itic1.htm"
		}, { "text": "What is your opinion about the following statements ", "id": "q21", "leaf": false, "cls": "folder", "children": [
		{"text": "I get more actively involved in courses that use information technology (IT)", "id": "q21a", "leaf": true, "cls": "folder", "url": "Report/q21a.htm"
		},{"text": "The use of IT in my courses improves my learning", "id": "q21b", "leaf": true, "cls": "folder", "url": "Report/q21b.htm"
		},{"text": "IT makes doing my course activities more convenient", "id": "q21c", "leaf": true, "cls": "folder", "url": "Report/q21c.htm"
		},{"text": "By the time I graduate, the IT I have used in my courses will have adequately prepared me for the workplace.", "id": "q21d", "leaf": true, "cls": "folder", "url": "Report/q21d.htm"
		},{"text": "My institution's IT services are always available when I need them for my coursework", "id": "q21e", "leaf": true, "cls": "folder", "url": "Report/q21e.htm"
		},{"text": "I skip classes when materials from course lectures are available online", "id": "q21f", "leaf": true, "cls": "folder", "url": "Report/q21f.htm"
		},{"text": "When I entered college, I was adequately prepared to use IT as needed in my course", "id": "q21g", "leaf": true, "cls": "folder", "url": "Report/q21g.htm"
		}]
		}, { "text": "Are you using the following for any of your courses this quarter/semester ", "id": "q12",  "leaf": false, "cls": "folder", "children": [
		{"text": "Spreadsheets (excel, etc.)", "id": "q12a", "leaf": true, "cls": "folder", "url": "Report/q12a.htm"
		},{"text": "Presentation software (PowerPoint, etc.)", "id": "q12b", "leaf": true, "cls": "folder", "url": "Report/q12b.htm"
		},{"text": "Graphics softwrae (Photoshop, Flash, etc.)", "id": "q12c", "leaf": true, "cls": "folder", "url": "Report/q12c.htm"
		},{"text": "Audio-creation software (Audacity, Garageband, etc.)", "id": "q12d", "leaf": true, "cls": "folder", "url": "Report/q12d.htm"
		},{"text": "Video-creation software (MovieMaker, iMovie, etc.)", "id": "q12e", "leaf": true, "cls": "folder", "url": "Report/q12e.htm"
		},{"text": "Programming languages (C++, Java, etc.)", "id": "q12f", "leaf": true, "cls": "folder", "url": "Report/q12f.htm"
		},{"text": "Course lecture podcasts or videos", "id": "q12g", "leaf": true, "cls": "folder", "url": "Report/q12g.htm"
		},{"text": "E-portfolios", "id": "q12h", "leaf": true, "cls": "folder", "url": "Report/q12h.htm"
		},{"text": "Discipline-specific technologies (Mathematica, AutoCAD, STELLA, etc.)", "id": "q12i", "leaf": true, "cls": "folder", "url": "Report/q12i.htm"
		},{"text": "Instant messaging", "id": "q12j", "leaf": true, "cls": "folder", "url": "Report/q12j.htm"
		},{"text": "Social networking websites (Facebook, MySpace, Bebo, Linkedin, etc.)", "id": "q12k", "leaf": true, "cls": "folder", "url": "Report/q12k.htm"
		},{"text": "Wikis (Wikipedia, course wiki, etc.)", "id": "q12l", "leaf": true, "cls": "folder", "url": "Report/q12l.htm"
		},{"text": "Blogs", "id": "q12m", "leaf": true, "cls": "folder", "url": "Report/q12m.htm"
		},{"text": "Online virtual worlds (Second Life, Forterra, etc.)", "id": "q12n", "leaf": true, "cls": "folder", "url": "Report/q12n.htm"
		},{"text": "College/university library website", "id": "q12o", "leaf": true, "cls": "folder", "url": "Report/q12o.htm"
		},{"text": "Simulations or educational games", "id": "q12p", "leaf": true, "cls": "folder", "url": "Report/q12p.htm"
		},{"text": "E-books or e-textbooks", "id": "q12q", "leaf": true, "cls": "folder", "url": "Report/q12q.htm"
		},{"text": "Clickers or student response systems", "id": "q12r", "leaf": true, "cls": "folder", "url": "Report/q12r.htm"
		}]
		},{ "text": "Are you using the following web-based tools for any of your courses this quarter/semester?", "id": "q13",  "leaf": false, "cls": "folder", "children": [
		{"text": "Web-based word processor, spreadsheet, presentation, and form applications (Google Docs, Zoho, etc.)", "id": "q13a", "leaf": true, "cls": "folder", "url": "Report/q13a.htm"
		},{"text": "Video-sharing websites (YouTube, etc.)", "id": "q13b", "leaf": true, "cls": "folder", "url": "Report/q13b.htm"
		},{"text": "Web-based to-do lists/task-managers (Remembering the Milk, Ta-da, etc.)", "id": "q13c", "leaf": true, "cls": "folder", "url": "Report/q13c.htm"
		},{"text": "Web-based calendars (Google Calendar, etc.)", "id": "q13d", "leaf": true, "cls": "folder", "url": "Report/q13d.htm"
		},{"text": "Photo-sharing websites (Flickr, Snapfish, Picasa, etc.)", "id": "q13e", "leaf": true, "cls": "folder", "url": "Report/q13e.htm"
		},{"text": "Web-based citation/bibliography tools (CiteULike, etc.)", "id": "q13f", "leaf": true, "cls": "folder", "url": "Report/q13f.htm"
		},{"text": "College-related review/opinions sites (RateMyProfessors, College Prowler, etc.)", "id": "q13g", "leaf": true, "cls": "folder", "url": "Report/q13g.htm"
		},{"text": "College study support (Cramster, turnitin, etc.)", "id": "q13h", "leaf": true, "cls": "folder", "url": "Report/q13h.htm"
		},{"text": "Textbook publisher resource websites (Pearson, PrenticeHall, etc.)", "id": "q13i", "leaf": true, "cls": "folder", "url": "Report/q13i.htm"
		},{"text": "Micro-blogs", "id": "q13j", "leaf": true, "cls": "folder", "url": "Report/q13j.htm"
		},{"text": "Social bookmarking/tagging (Delicious, Digg, etc.)", "id": "q13k", "leaf": true, "cls": "folder", "url": "Report/q13k.htm"
		}]
		},{ "text": "Are you collaborating or working with other students using any of the following web-based tools for any of your courses this quarter/semester? ", "id": "q14",  "leaf": false, "cls": "folder", "children": [
		{"text": "Web-based word processor, spreadsheet, presentation, and form application (google Docs, iWork, etc.)", "id": "q14a", "leaf": true, "cls": "folder", "url": "Report/q14a.htm"
		},{"text": "Video-sharing websites (YouTube, etc.)", "id": "q14b", "leaf": true, "cls": "folder", "url": "Report/q14b.htm"
		},{"text": "Photo-sharing websites (Flickr, Snapfish, etc.)", "id": "q14c", "leaf": true, "cls": "folder", "url": "Report/q14c.htm"
		},{"text": "Web-based citation/bibliography tools (CiteULike, OttoBib, etc.)", "id": "q14d", "leaf": true, "cls": "folder", "url": "Report/q14d.htm"
		},{"text": "Textbook publisher resource websites (Pearson, PrenticeHall, etc.)", "id": "q14e", "leaf": true, "cls": "folder", "url": "Report/q14e.htm"
		},{"text": "Micro-blogs (Twitter, etc.)", "id": "q14f", "leaf": true, "cls": "folder", "url": "Report/q14f.htm"
		},{"text": "Social bookmarking/tagging (Delicious, Digg, etc.)", "id": "q14g", "leaf": true, "cls": "folder", "url": "Report/q14g.htm"
		},{"text": "Social networking websites (Facebook, MySpace, etc.)", "id": "q14h", "leaf": true, "cls": "folder", "url": "Report/q14h.htm"
		},{"text": "Wikis (Wikipedia, course wiki, etc.)", "id": "q14i", "leaf": true, "cls": "folder", "url": "Report/q14i.htm"
		},{"text": "Blogs", "id": "q14j", "leaf": true, "cls": "folder", "url": "Report/q14j.htm"
		},{"text": "Online virtual worlds (Second Life, etc.)", "id": "q14k", "leaf": true, "cls": "folder", "url": "Report/q14k.htm"
		}]
		},{"text": "How many of your courses this quarter/semester are entirely online?", "id": "q20", "leaf": true, "cls": "folder", "url": "Report/q20.htm"
		},{"text": "How many of your instructors:", "id": "q15","leaf": false, "cls": "folder", "children": [
		{"text": "Use information technology (IT) effectively in courses", "id": "q15a", "leaf": true, "cls": "folder", "url": "Report/q15a.htm"
		},{"text": "Provide students with adequate training for the IT the instructor uses in his or her course", "id": "q15b", "leaf": true, "cls": "folder", "url": "Report/q15b.htm"
		},{"text": "Have adequate IT skills for carrying out course instruction", "id": "q15c", "leaf": true, "cls": "folder", "url": "Report/q15c.htm"
		}]
		},{"text": "Which best describes your preference?", "id": "itic5", "leaf": true, "cls": "folder", "url": "Report/q10.htm"
		},{"text": "Are you using a course or learning management system for any of your course this quarter/semester?", "id": "q17", "leaf": true, "cls": "folder", "url": "Report/q17.htm"
		},{"text": "How often do you use course or learning management systems", "id": "q16", "leaf": true, "cls": "folder", "url": "Report/q16.htm"
		},{"text": "What is your skill level using course or learning management systems?", "id": "q18", "leaf": true, "cls": "folder", "url": "Report/q18.htm"
		},{"text": "Describe your overall experience using course or learning management systems", "id": "q19", "leaf": true, "cls": "folder", "url": "Report/q19.htm"
		}]
		}
,{"text": "Social Netwoking Websites", "id": 104, "leaf": false, "cls": "folder", "children": [
		{ "text": "Which of the following social networking websites do you use? ", "id": "q25", "leaf": false, "cls": "folder", "children": [
		{"text": "Bebo", "id": "q25a", "leaf": true, "cls": "folder", "url": "Report/q25a.htm"
		},{"text": "Facebook", "id": "q25b", "leaf": true, "cls": "folder", "url": "Report/q25b.htm"
		},{"text": "Linkedin", "id": "q25c", "leaf": true, "cls": "folder", "url": "Report/q25c.htm"
		},{"text": "MySpace", "id": "q25d", "leaf": true, "cls": "folder", "url": "Report/q25d.htm"
		},{"text": "Tagged", "id": "q25e", "leaf": true, "cls": "folder", "url": "Report/q25e.htm"
		},{"text": "myYearbook", "id": "q25f", "leaf": true, "cls": "folder", "url": "Report/q25f.htm"
		},{"text": "Classmates", "id": "q25g", "leaf": true, "cls": "folder", "url": "Report/q25g.htm"
		},{"text": "Flickr", "id": "q25h", "leaf": true, "cls": "folder", "url": "Report/q25h.htm"
		},{"text": "Other", "id": "q25i", "leaf": true, "cls": "folder", "url": "Report/q25i.htm"
		}]
		}, { "text": "How do you use social networking websites?", "id": "q26", "leaf": false, "cls": "folder", "children": [
		{"text": "Stay in touch with friends", "id": "q26a", "leaf": true, "cls": "folder", "url": "Report/q26a.htm"
		},{"text": "Make new friends I have never met in person", "id": "q26b", "leaf": true, "cls": "folder", "url": "Report/q26b.htm"
		},{"text": "Find out more about people (I may or may not have met)", "id": "q26c", "leaf": true, "cls": "folder", "url": "Report/q26c.htm"
		},{"text": "As a forum to express my opinions and views", "id": "q26d", "leaf": true, "cls": "folder", "url": "Report/q26d.htm"
		},{"text": "Share photos, music, videos, or other work", "id": "q26e", "leaf": true, "cls": "folder", "url": "Report/q26e.htm"
		},{"text": "For professional activities (job networking, etc.)", "id": "q26f", "leaf": true, "cls": "folder", "url": "Report/q26f.htm"
		},{"text": "Participate in special-interest groups", "id": "q26g", "leaf": true, "cls": "folder", "url": "Report/q26g.htm"
		},{"text": "Plan or invite people to events", "id": "q26h", "leaf": true, "cls": "folder", "url": "Report/q26h.htm"
		},{"text": "Play games", "id": "q26i", "leaf": true, "cls": "folder", "url": "Report/q26i.htm"
		},{"text": "Follow/interact with my college's or university's social/extracurricular activities (athletics, clubs, arts, etc.)", "id": "q26j", "leaf": true, "cls": "folder", "url": "Report/q26j.htm"
		},{"text": "Use my college's or university's administrative services or communicate with administrative offices (registration, advising, financial aid, billing, etc.)", "id": "q26k", "leaf": true, "cls": "folder", "url": "Report/q26k.htm"
		},{"text": "Communicate with classmates about course-related topics", "id": "q26l", "leaf": true, "cls": "folder", "url": "Report/q26l.htm"
		},{"text": "Communicate with instructors about course-related topics", "id": "q26m", "leaf": true, "cls": "folder", "url": "Report/q26m.htm"
		},{"text": "Other", "id": "q26n", "leaf": true, "cls": "folder", "url": "Report/q26n.htm"
		}]
		}, { "text": "How often do you use social networking websites for school, work, or recreation", "id": "q24", "leaf": true, "cls": "folder", "url": "Report/q24.htm"
},{ "text": "Do you limit or restrict who has access to your profiles on social networking sites? ", "id": "q27", "leaf": true, "cls": "folder", "url": "Report/q27.htm"
		}, { "text": "Are any of your current or previous college or university instructors among the people you've accepted as friends or contacts on social networking sites?", "id": "q28", "leaf": true, "cls": "folder", "url": "Report/q28.htm"
}, { "text": "Would you like to see more use of social networking websites in your courses?", "id": "q29", "leaf": true, "cls": "folder", "url": "Report/q29.htm"
}]
		
		},{"text": "Data Tables", "id": "data_tables","leaf": false, "cls": "folder", "children": [
		{"text": "Daytona Beach", "id": "db_datatables", "leaf": true, "cls": "folder", "url": "Report/db_datatables.htm"
		},{"text": "Prescott", "id": "pc_datatables", "leaf": true, "cls": "folder", "url": "Report/pc_datatables.htm"
		},{"text": "Worldwide", "id": "ww_datatables", "leaf": true, "cls": "folder", "url": "Report/ww_datatables.htm"
		}]
		}]
		}
		];

		var filter = new Ext.tree.TreeFilter(tree, {
			clearBlank: true,
			autoClear: true
		});
		
		tree.on({
		click:{stopEvent:true, fn:function(n, e) {
			e.stopEvent();
			// handle detail
			if(n.parentNode && n.parentNode.id) {
				if(Ext.fly('detail-' + n.parentNode.id)) {
					showDetail(n.parentNode.id);
				}
			}
			if(n.id) {
				if(Ext.fly('detail-' + n.id)) {
					showDetail(n.id);
				}
			}
			if(!n.isLeaf()) {
				n.toggle();
			}

	}}
	});

		var hiddenPkgs = [];
		function filterTree(e) {
			var text = e.target.value;
			Ext.each(hiddenPkgs, function(n) {
				n.ui.show();
			});
			if (!text) {
				filter.clear();
				return;
			}
//			tree.expandAll();

			var re = new RegExp(Ext.escapeRe(text), 'i');
			filter.filterBy(function(n) {
				return !n.attributes.isClass || re.test(n.text);
			});

			// hide empty packages that weren't filtered
			hiddenPkgs = [];
			tree.root.cascade(function(n) {
				if (!n.attributes.isClass && !re.test(n.text) && n.ui.ctNode.offsetHeight < 3) {
					n.ui.hide();
					hiddenPkgs.push(n);
				}
			});
		}

		var root = new Ext.tree.AsyncTreeNode({
			text: 'Autos',
			draggable: false,
			id: 'source',
			children: json
		});

		tree.setRootNode(root);
		this.navigation = tree;

		tree.on('click', MyApp.NavigationClick, this);
		return tree;
	},


	createCenter: function() {
		
		var defaultPanel = new Ext.TabPanel({
			region: 'center',
			enableTabScroll:true,
			defaults: {autoScroll:true},
			closable: false
			
		});
		
		var welcomeTab = new Ext.Panel({
			title: 'ECAR Survey',
			layout: 'border',
			
			border: false,
			region: 'center',
			items: [defaultPanel]
		});

		var tabPanel = new Ext.TabPanel({
			region: 'center',
			activeTab: 0,
			items: [
				welcomeTab
			]
		});
		this.defaultPanel = defaultPanel;

		return tabPanel;
	},

	render: function() {
		var west = this.createWest();
		var center = this.createCenter();

		var vp = new Ext.Viewport({
			layout: 'border',
			items: [west, center]
		});

		var rootNode = west.root;
		MyApp.MainPanel.openNode(rootNode);
	},

	openNode: function(rootNode) {
		var getParams = document.URL.split("?");
		var queryParams = Ext.urlDecode(getParams[getParams.length - 1].replace(/\+/g, " ").replace("#", ""));
		var getParamValue = function(param) {
			param = param.toLowerCase();
			for (var propName in queryParams) {
				if (propName.toLowerCase() == param) {
					return queryParams[propName];
				}
			}
		}
		var nodeId = getParamValue("node");
		if (nodeId != '' && nodeId != undefined) {
			var nodes = nodeId.split(',');
			//MyApp.MainPanel.navigation.root.ownerTree.root.expand(true);
			for (var i = 0; i < nodes.length; i++) {
				var node = MyApp.MainPanel.navigation.root.ownerTree.root.childNodes[0].findChild('text', nodes[i])
				if (node) {
					MyApp.NavigationClick(node);
				}
			}
			MyApp.MainPanel.navigation.root.ownerTree.root.collapse(true);
		}
	}
});

Ext.onReady(function() {
	MyApp.MainPanel.render();
});