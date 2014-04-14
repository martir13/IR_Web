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
		}, { "text": "Most Recent Survey Instrument", "id": "h1001", "leaf": true, "cls": "folder", "url": "Survey Instrument/index.htm", "html": "Amit, Amit"
		}, { "text": "Most Recent IR Preview", "id": "h1002", "leaf": true, "cls": "folder", "url": "IR Preview/index.htm", "html": "Amit, Amit"
		}]
		
		},
		{ "text": "Report", "id": 2000, "cls": "folder", "children": [
		
		{ "text": "Overview", "id": "s1000", "leaf": true, "cls": "folder", "url": "2009/index.htm", "html": "Amit, Amit"
		},{ "text": "Survey Instrument", "id": "s1002", "leaf": true, "cls": "folder", "url": "Survey Instrument/index.htm", "html": "Amit, Amit"
		}, { "text": "IR Preview", "id": "s1003", "leaf": true, "cls": "folder", "url": "IR Preview/index.htm", "html": "Amit, Amit"
		}, { "text": "Academic Advising", "id": 103, "expanded": false, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 3456, "cls": "folder", "children": [
		{ "text": "My academic advisor is approachable", "id": "ai1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS01", "leaf": true, "cls": "folder", "url": "report/aic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS02", "leaf": true, "cls": "folder", "url": "report/aid1.htm" 
			},
		]},{ "text": "My academic advisor is concerned about my success as an individual", "id": "ai2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS03", "leaf": true, "cls": "folder", "url": "report/aic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS04", "leaf": true, "cls": "folder", "url": "report/aid2.htm" 
			},
		]},{ "text": "My academic advisor helps me set goals to work toward", "id": "ai3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS05", "leaf": true, "cls": "folder", "url": "report/aic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS06", "leaf": true, "cls": "folder", "url": "report/aid3.htm" 
			},
		]},{ "text": "My academic advisor is knowledgeable about requirements in my major", "id": "ai4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS07", "leaf": true, "cls": "folder", "url": "report/aic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS08", "leaf": true, "cls": "folder", "url": "report/aid4.htm" 
			},
		]},{ "text": "Major requirements are clear and reasonable", "id": "ai5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS09", "leaf": true, "cls": "folder", "url": "report/aic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS10", "leaf": true, "cls": "folder", "url": "report/aid5.htm" 
			},
		]},
		
		
		] },
		{ "text": "Satisfaction", "id": 3457, "cls": "folder", "children": [
		{ "text": "My academic advisor is approachable", "id": "asi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS01", "leaf": true, "cls": "folder", "url": "report/asc1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS02", "leaf": true, "cls": "folder", "url": "report/asd1.htm" 
			},
		]},{ "text": "My academic advisor is concerned about my success as an individual", "id": "as2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS03", "leaf": true, "cls": "folder", "url": "report/asc2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS04", "leaf": true, "cls": "folder", "url": "report/asd2.htm" 
			},
		]},{ "text": "My academic advisor helps me set goals to work toward", "id": "as3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS05", "leaf": true, "cls": "folder", "url": "report/asc3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS06", "leaf": true, "cls": "folder", "url": "report/asd3.htm" 
			},
		]},{ "text": "My academic advisor is knowledgeable about requirements in my major", "id": "as4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS07", "leaf": true, "cls": "folder", "url": "report/asc4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS08", "leaf": true, "cls": "folder", "url": "report/asd4.htm" 
			},
		]},{ "text": "Major requirements are clear and reasonable", "id": "as5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS09", "leaf": true, "cls": "folder", "url": "report/asc5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS10", "leaf": true, "cls": "folder", "url": "report/asd5.htm" 
			},
		]},
		
		
		] },
		]},{"text": "Campus Climate", "id": 101, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4001, "cls": "folder", "children": [
		{ "text": "Most students feel a sense of belonging here", "id": "cci1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ccS01", "leaf": true, "cls": "folder", "url": "report/ccic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS02", "leaf": true, "cls": "folder", "url": "report/ccid1.htm" 
			},
		]},{ "text": "The campus staff are caring and helpful", "id": "cci2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS03", "leaf": true, "cls": "folder", "url": "report/ccic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS04", "leaf": true, "cls": "folder", "url": "report/ccid2.htm" 
			},
		]},{ "text": "Administrators are approachable to students", "id": "cci3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS05", "leaf": true, "cls": "folder", "url": "report/ccic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS06", "leaf": true, "cls": "folder", "url": "report/ccid3.htm" 
			},
		]},{ "text": "It is an enjoyable experience to be a student on this campus", "id": "cci4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS07", "leaf": true, "cls": "folder", "url": "report/ccic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS08", "leaf": true, "cls": "folder", "url": "report/ccid4.htm" 
			},
		]},{ "text": "I feel a sense of pride about my campus", "id": "cci5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS09", "leaf": true, "cls": "folder", "url": "report/ccic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS10", "leaf": true, "cls": "folder", "url": "report/ccid5.htm" 
			},
		]},{ "text": "Students are made to feel welcome on this campus", "id": "cci6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS11", "leaf": true, "cls": "folder", "url": "report/ccic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS12", "leaf": true, "cls": "folder", "url": "report/ccid6.htm" 
			},
		]},{ "text": "This institution has a good reputation within the community", "id": "cci7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS13", "leaf": true, "cls": "folder", "url": "report/ccic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS14", "leaf": true, "cls": "folder", "url": "report/ccid7.htm" 
			},
		]},{ "text": "There is a strong commitment to racial harmony on this campus", "id": "cci8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS15", "leaf": true, "cls": "folder", "url": "report/ccic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS16", "leaf": true, "cls": "folder", "url": "report/ccid8.htm" 
			},
		]},{ "text": "Tuition paid is a worthwile investment", "id": "cci9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS17", "leaf": true, "cls": "folder", "url": "report/ccic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS18", "leaf": true, "cls": "folder", "url": "report/ccid9.htm" 
			},
		]},{ "text": "Freedom of expresson is protected on campus", "id": "cci10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS19", "leaf": true, "cls": "folder", "url": "report/ccic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS20", "leaf": true, "cls": "folder", "url": "report/ccid10.htm" 
			},
		]},{ "text": "Channels for expressing student complaints are readily available", "id": "cci11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCS21", "leaf": true, "cls": "folder", "url": "report/ccic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCS22", "leaf": true, "cls": "folder", "url": "report/ccid11.htm" 
			},
		]},
		
		
		] },
		{ "text": "Satisfaction", "id": 4002, "cls": "folder", "children": [
		{ "text": "Most students feel a sense of belonging here", "id": "ccs1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS01", "leaf": true, "cls": "folder", "url": "report/ccsic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS02", "leaf": true, "cls": "folder", "url": "report/ccsid1.htm" 
			},
		]},{ "text": "The campus staff are caring and helpful", "id": "ccsi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS03", "leaf": true, "cls": "folder", "url": "report/ccsic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS04", "leaf": true, "cls": "folder", "url": "report/ccsid2.htm" 
			},
		]},{ "text": "Administrators are approachable to students", "id": "ccsi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS05", "leaf": true, "cls": "folder", "url": "report/ccsic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS06", "leaf": true, "cls": "folder", "url": "report/ccsid3.htm" 
			},
		]},{ "text": "It is an enjoyable experience to be a student on this campus", "id": "ccsi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS07", "leaf": true, "cls": "folder", "url": "report/ccsic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS08", "leaf": true, "cls": "folder", "url": "report/ccsid4.htm" 
			},
		]},{ "text": "I feel a sense of pride about my campus", "id": "ccsi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS09", "leaf": true, "cls": "folder", "url": "report/ccsic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS10", "leaf": true, "cls": "folder", "url": "report/ccsid5.htm" 
			},
		]},{ "text": "Students are made to feel welcome on this campus", "id": "ccsi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS11", "leaf": true, "cls": "folder", "url": "report/ccsic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS12", "leaf": true, "cls": "folder", "url": "report/ccsid6.htm" 
			},
		]},{ "text": "This institution has a good reputation within the community", "id": "ccsi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS13", "leaf": true, "cls": "folder", "url": "report/ccsic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS14", "leaf": true, "cls": "folder", "url": "report/ccsid7.htm" 
			},
		]},{ "text": "There is a strong commitment to racial harmony on this campus", "id": "ccsi8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS15", "leaf": true, "cls": "folder", "url": "report/ccsic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS16", "leaf": true, "cls": "folder", "url": "report/ccsid8.htm" 
			},
		]},{ "text": "Tuition paid is a worthwile investment", "id": "ccsi9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS17", "leaf": true, "cls": "folder", "url": "report/ccsic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS18", "leaf": true, "cls": "folder", "url": "report/ccsid9.htm" 
			},
		]},{ "text": "Freedom of expresson is protected on campus", "id": "ccsi10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS19", "leaf": true, "cls": "folder", "url": "report/ccsic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS20", "leaf": true, "cls": "folder", "url": "report/ccsid10.htm" 
			},
		]},{ "text": "Channels for expressing student complaints are readily available", "id": "ccsi11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CCSS21", "leaf": true, "cls": "folder", "url": "report/ccsic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "CCSS22", "leaf": true, "cls": "folder", "url": "report/ccsid11.htm" 
			},
		]},
		]},
		]},{"text": "Campus Life", "id": 104, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4003, "cls": "folder", "children": [
		{ "text": "A variety of intramural activities are offered", "id": "cli1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS01", "leaf": true, "cls": "folder", "url": "report/clic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS02", "leaf": true, "cls": "folder", "url": "report/clid1.htm" 
			},
		]},{ "text": "Living conditions in the residence halls are comfortable", "id": "cli2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS03", "leaf": true, "cls": "folder", "url": "report/clic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS04", "leaf": true, "cls": "folder", "url": "report/clid2.htm" 
			},
		]},{ "text": "The intercollegiate athletic programs contribute to a strong sense of school spirit", "id": "cli3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS05", "leaf": true, "cls": "folder", "url": "report/clic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS06", "leaf": true, "cls": "folder", "url": "report/clid3.htm" 
			},
		]},{ "text": "Males and females have equal opportunities to participate in intercollegiate athletics", "id": "cli4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS07", "leaf": true, "cls": "folder", "url": "report/clic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS08", "leaf": true, "cls": "folder", "url": "report/clid4.htm" 
			},
		]},{ "text": "There is an adequate selection of food available in the cafeteria", "id": "cli5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS09", "leaf": true, "cls": "folder", "url": "report/clic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS10", "leaf": true, "cls": "folder", "url": "report/clid5.htm" 
			},
		]},{ "text": "Residence hall regulations are reasonable", "id": "cli6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS11", "leaf": true, "cls": "folder", "url": "report/clic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS12", "leaf": true, "cls": "folder", "url": "report/clid6.htm" 
			},
		]},{ "text": "There are a sufficient number of weekend activities for students", "id": "cli7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS13", "leaf": true, "cls": "folder", "url": "report/clic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS14", "leaf": true, "cls": "folder", "url": "report/clid7.htm" 
			},
		]},{ "text": "I can easily get involved in campus organizations", "id": "cli8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS15", "leaf": true, "cls": "folder", "url": "report/clic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS16", "leaf": true, "cls": "folder", "url": "report/clid8.htm" 
			},
		]},{ "text": "The student center is a comfortable place for students to spend their leisure time", "id": "cli9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS17", "leaf": true, "cls": "folder", "url": "report/clic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS18", "leaf": true, "cls": "folder", "url": "report/clid9.htm" 
			},
		]},{ "text": "The student handbook provides helpful information about campus life", "id": "cli10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS19", "leaf": true, "cls": "folder", "url": "report/clic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS20", "leaf": true, "cls": "folder", "url": "report/clid10.htm" 
			},
		]},{ "text": "Student discipline procedures are fair", "id": "cli11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS21", "leaf": true, "cls": "folder", "url": "report/clic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS22", "leaf": true, "cls": "folder", "url": "report/clid11.htm" 
			},
		]},{ "text": "New Student orientation services help students adjust to college", "id": "cli12", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS23", "leaf": true, "cls": "folder", "url": "report/clic12.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS24", "leaf": true, "cls": "folder", "url": "report/clid12.htm" 
			},
		]},{ "text": "S.G.A. fees are put to good use", "id": "cli13", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLS25", "leaf": true, "cls": "folder", "url": "report/clic13.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLS26", "leaf": true, "cls": "folder", "url": "report/clid13.htm" 
			},
		]},
		
		
		] },
		{ "text": "Satisfaction", "id": 4004, "cls": "folder", "children": [
		{ "text": "A variety of intramural activities are offered", "id": "clsi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS01", "leaf": true, "cls": "folder", "url": "report/clsic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS02", "leaf": true, "cls": "folder", "url": "report/clsid1.htm" 
			},
		]},{ "text": "Living conditions in the residence halls are comfortable", "id": "clsi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS03", "leaf": true, "cls": "folder", "url": "report/clsic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS04", "leaf": true, "cls": "folder", "url": "report/clsid2.htm" 
			},
		]},{ "text": "The intercollegiate athletic programs contribute to a strong sense of school spirit", "id": "clsi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS05", "leaf": true, "cls": "folder", "url": "report/clsic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS06", "leaf": true, "cls": "folder", "url": "report/clsid3.htm" 
			},
		]},{ "text": "Males and females have equal opportunities to participate in intercollegiate athletics", "id": "clsi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS07", "leaf": true, "cls": "folder", "url": "report/clsic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS08", "leaf": true, "cls": "folder", "url": "report/clsid4.htm" 
			},
		]},{ "text": "There is an adequate selection of food available in the cafeteria", "id": "clsi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS09", "leaf": true, "cls": "folder", "url": "report/clsic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS10", "leaf": true, "cls": "folder", "url": "report/clsid5.htm" 
			},
		]},{ "text": "Residence hall regulations are reasonable", "id": "clsi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS11", "leaf": true, "cls": "folder", "url": "report/clsic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS12", "leaf": true, "cls": "folder", "url": "report/clsid6.htm" 
			},
		]},{ "text": "There are a sufficient number of weekend activities for students", "id": "clsi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS13", "leaf": true, "cls": "folder", "url": "report/clsic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS14", "leaf": true, "cls": "folder", "url": "report/clsid7.htm" 
			},
		]},{ "text": "I can easily get involved in campus organizations", "id": "clsi8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS15", "leaf": true, "cls": "folder", "url": "report/clsic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS16", "leaf": true, "cls": "folder", "url": "report/clsid8.htm" 
			},
		]},{ "text": "The student center is a comfortable place for students to spend their leisure time", "id": "clsi9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS17", "leaf": true, "cls": "folder", "url": "report/clsic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS18", "leaf": true, "cls": "folder", "url": "report/clsid9.htm" 
			},
		]},{ "text": "The student handbook provides helpful information about campus life", "id": "clsi10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS19", "leaf": true, "cls": "folder", "url": "report/clsic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS20", "leaf": true, "cls": "folder", "url": "report/clsid10.htm" 
			},
		]},{ "text": "Student discipline procedures are fair", "id": "clsi11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS21", "leaf": true, "cls": "folder", "url": "report/clsic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS22", "leaf": true, "cls": "folder", "url": "report/clsid11.htm" 
			},
		]},{ "text": "New Student orientation services help students adjust to college", "id": "clsi12", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS23", "leaf": true, "cls": "folder", "url": "report/clsic12.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS24", "leaf": true, "cls": "folder", "url": "report/clsid12.htm" 
			},
		]},{ "text": "S.G.A. fees are put to good use", "id": "clsi13", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CLSS25", "leaf": true, "cls": "folder", "url": "report/clsic13.htm" 
		},
		{"text": "Degree Program Trend", "id": "CLSS26", "leaf": true, "cls": "folder", "url": "report/clsid13.htm" 
			},
		]},
		
		
		] },

		]},{"text": "Campus Support Services", "id": 105, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4234, "cls": "folder", "children": [
		{ "text": "Library staff are helpful and approachable", "id": "cssi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS01", "leaf": true, "cls": "folder", "url": "report/cssic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS02", "leaf": true, "cls": "folder", "url": "report/cssid1.htm" 
			},
		]},{ "text": "Library resources and services are adequate", "id": "cssi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS03", "leaf": true, "cls": "folder", "url": "report/cssic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS04", "leaf": true, "cls": "folder", "url": "report/cssid2.htm" 
			},
		]},{ "text": "Computer Labs are adequate and accessible", "id": "cssi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS05", "leaf": true, "cls": "folder", "url": "report/cssic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS06", "leaf": true, "cls": "folder", "url": "report/cssid3.htm" 
			},
		]},{ "text": "Tutoring services are readily available", "id": "cssi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSS07", "leaf": true, "cls": "folder", "url": "report/cssic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSS08", "leaf": true, "cls": "folder", "url": "report/cssid4.htm" 
			},
		]},{ "text": "Academic support services adequately meet the needs of students", "id": "cssi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS09", "leaf": true, "cls": "folder", "url": "report/cssic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS10", "leaf": true, "cls": "folder", "url": "report/cssid5.htm" 
			},
		]},{ "text": "There are adequate services to help me decide upon a career", "id": "cssi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS11", "leaf": true, "cls": "folder", "url": "report/cssic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS12", "leaf": true, "cls": "folder", "url": "report/cssid6.htm" 
			},
		]},{ "text": "Bookstore staff are helpful", "id": "cssi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS13", "leaf": true, "cls": "folder", "url": "report/cssic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS14", "leaf": true, "cls": "folder", "url": "report/cssid7.htm" 
			},
		]},
		
		
		] },
		{ "text": "Satisfaction", "id": 4005, "cls": "folder", "children": [
				{ "text": "Library staff are helpful and approachable", "id": "csssi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS01", "leaf": true, "cls": "folder", "url": "report/csssic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS02", "leaf": true, "cls": "folder", "url": "report/csssid1.htm" 
			},
		]},{ "text": "Library resources and services are adequate", "id": "csssi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS03", "leaf": true, "cls": "folder", "url": "report/csssic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS04", "leaf": true, "cls": "folder", "url": "report/csssid2.htm" 
			},
		]},{ "text": "Computer Labs are adequate and accessible", "id": "csssi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS05", "leaf": true, "cls": "folder", "url": "report/csssic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS06", "leaf": true, "cls": "folder", "url": "report/csssid3.htm" 
			},
		]},{ "text": "Tutoring services are readily available", "id": "csssi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSS07", "leaf": true, "cls": "folder", "url": "report/csssic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSS08", "leaf": true, "cls": "folder", "url": "report/csssid4.htm" 
			},
		]},{ "text": "Academic support services adequately meet the needs of students", "id": "csssi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS09", "leaf": true, "cls": "folder", "url": "report/csssic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS10", "leaf": true, "cls": "folder", "url": "report/csssid5.htm" 
			},
		]},{ "text": "There are adequate services to help me decide upon a career", "id": "csssi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS11", "leaf": true, "cls": "folder", "url": "report/csssic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS12", "leaf": true, "cls": "folder", "url": "report/csssid6.htm" 
			},
		]},{ "text": "Bookstore staff are helpful", "id": "csssi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSSSS13", "leaf": true, "cls": "folder", "url": "report/csssic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSSSS14", "leaf": true, "cls": "folder", "url": "report/csssid7.htm" 
			},
		]},
		
		
		] },

		]},{"text": "Concern for the individual", "id": 106, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4006, "cls": "folder", "children": [
		{ "text": "Faculty care about me as an individual", "id": "cfii1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFI01", "leaf": true, "cls": "folder", "url": "report/cfiic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFI02", "leaf": true, "cls": "folder", "url": "report/cfiid1.htm" 
			},
		]},{ "text": "Counseling staff care about students as individuals", "id": "cfii2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFI03", "leaf": true, "cls": "folder", "url": "report/cfiic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFI04", "leaf": true, "cls": "folder", "url": "report/cfiid2.htm" 
			},
		]},{ "text": "Residence hall staff are concerned about me as an individual", "id": "cfii3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFI05", "leaf": true, "cls": "folder", "url": "report/cfiic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFI06", "leaf": true, "cls": "folder", "url": "report/cfiid3.htm" 
			},
		]},{ "text": "This institution shows concern for students as individuals", "id": "cfii4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFI07", "leaf": true, "cls": "folder", "url": "report/cfiic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFI08", "leaf": true, "cls": "folder", "url": "report/cfiid4.htm" 
			},
		]},
		
		] },
		{ "text": "Satisfaction", "id": 4007, "cls": "folder", "children": [
				{ "text": "Faculty care about me as an individual", "id": "cfisi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFIS01", "leaf": true, "cls": "folder", "url": "report/cfisic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFIS02", "leaf": true, "cls": "folder", "url": "report/cfisid1.htm" 
			},
		]},{ "text": "Counseling staff care about students as individuals", "id": "cfisi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFIS03", "leaf": true, "cls": "folder", "url": "report/cfisic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFIS04", "leaf": true, "cls": "folder", "url": "report/cfisid2.htm" 
			},
		]},{ "text": "Residence hall staff are concerned about me as an individual", "id": "cfisi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFIS05", "leaf": true, "cls": "folder", "url": "report/cfisic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFIS06", "leaf": true, "cls": "folder", "url": "report/cfisid3.htm" 
			},
		]},{ "text": "This institution shows concern for students as individuals", "id": "cfisi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFIS07", "leaf": true, "cls": "folder", "url": "report/cfisic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CFI08", "leaf": true, "cls": "folder", "url": "report/cfisid4.htm" 
			},
		]},
		
		] },
		]},
		
	{"text": "Safety and Security", "id": 107, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4008, "cls": "folder", "children": [
		{ "text": "The campus is safe and secure for all students", "id": "cfsasi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASI01", "leaf": true, "cls": "folder", "url": "report/csasic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASI02", "leaf": true, "cls": "folder", "url": "report/csasid1.htm" 
			},
		]},{ "text": "The amount of student parking space on campus is adequate", "id": "cfsasi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASI03", "leaf": true, "cls": "folder", "url": "report/cfsasic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASI04", "leaf": true, "cls": "folder", "url": "report/cfsasid2.htm" 
			},
		]},{ "text": "Parking lots are well-lighted and secure", "id": "cfsasi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFSAS05", "leaf": true, "cls": "folder", "url": "report/cfsasic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSAS06", "leaf": true, "cls": "folder", "url": "report/cfsasid3.htm" 
			},
		]},{ "text": "Security staff respond quickly in emergencies", "id": "cfsasi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASI07", "leaf": true, "cls": "folder", "url": "report/cfsasic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASI08", "leaf": true, "cls": "folder", "url": "report/cfsasid4.htm" 
			},
		]},
		
		] },
		{ "text": "Satisfaction", "id": 4009, "cls": "folder", "children": [
				{ "text": "The campus is safe and secure for all students", "id": "cfsassi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASSI01", "leaf": true, "cls": "folder", "url": "report/csassic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASSI02", "leaf": true, "cls": "folder", "url": "report/csassid1.htm" 
			},
		]},{ "text": "The amount of student parking space on campus is adequate", "id": "cfsassi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASSI03", "leaf": true, "cls": "folder", "url": "report/cfsassic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASSI04", "leaf": true, "cls": "folder", "url": "report/cfsassid2.htm" 
			},
		]},{ "text": "Parking lots are well-lighted and secure", "id": "cfsassi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CFSASS05", "leaf": true, "cls": "folder", "url": "report/cfsassic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASS06", "leaf": true, "cls": "folder", "url": "report/cfsassid3.htm" 
			},
		]},{ "text": "Security staff respond quickly in emergencies", "id": "cfsassi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "CSASSI07", "leaf": true, "cls": "folder", "url": "report/cfsassic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "CSASSI08", "leaf": true, "cls": "folder", "url": "report/cfsassid4.htm" 
			},
		]},
		
		] },
		]},
		{"text": "Institutional Effectiveness", "id": 108, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4010, "cls": "folder", "children": [
		{ "text": "The content of the course within my major is valuable", "id": "iei1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI01", "leaf": true, "cls": "folder", "url": "report/ieic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI02", "leaf": true, "cls": "folder", "url": "report/ieid1.htm" 
			},
		]},{ "text": "The instruction in my major field is excellent", "id": "iei2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI03", "leaf": true, "cls": "folder", "url": "report/ieic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI04", "leaf": true, "cls": "folder", "url": "report/ieid2.htm" 
			},
		]},{ "text": "Faculty are fair and unbiased in their treatment of individual students", "id": "iei3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ie05", "leaf": true, "cls": "folder", "url": "report/ieic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "IE06", "leaf": true, "cls": "folder", "url": "report/ieid3.htm" 
			},
		]},{ "text": "I am able to experience intellectual growth here", "id": "iei4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI07", "leaf": true, "cls": "folder", "url": "report/ieic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI08", "leaf": true, "cls": "folder", "url": "report/ieid4.htm" 
			},
		]},{ "text": "There is a commitment to academic excellence on this campus", "id": "iei5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI09", "leaf": true, "cls": "folder", "url": "report/ieic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI10", "leaf": true, "cls": "folder", "url": "report/ieid5.htm" 
			},
		]},{ "text": "Faculty provide timely feedback about student progress in a course", "id": "iei6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI11", "leaf": true, "cls": "folder", "url": "report/ieic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI12", "leaf": true, "cls": "folder", "url": "report/ieid6.htm" 
			},
		]},{ "text": "Faculty take into consideration student differences as they teach a course", "id": "iei7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI13", "leaf": true, "cls": "folder", "url": "report/ieic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI14", "leaf": true, "cls": "folder", "url": "report/ieid7.htm" 
			},
		]},{ "text": "The quality of instruction I receive in most of my classes is excellent", "id": "iei8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI15", "leaf": true, "cls": "folder", "url": "report/ieic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI16", "leaf": true, "cls": "folder", "url": "report/ieid8.htm" 
			},
		]},{ "text": "Adjunct faculty are competent as classroom instructors", "id": "iei9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI17", "leaf": true, "cls": "folder", "url": "report/ieic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI18", "leaf": true, "cls": "folder", "url": "report/ieid9.htm" 
			},
		]},{ "text": "Faculty are usually available after class and during office hours", "id": "iei10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI19", "leaf": true, "cls": "folder", "url": "report/ieic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI20", "leaf": true, "cls": "folder", "url": "report/ieid10.htm" 
			},
		]},{ "text": "Nearly all of the faculty are knowledgeable in their field", "id": "iei11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI20", "leaf": true, "cls": "folder", "url": "report/ieic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI21", "leaf": true, "cls": "folder", "url": "report/ieid11.htm" 
			},
		]},{ "text": "There is a good variety of courses offered on this campus", "id": "iei12", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI22", "leaf": true, "cls": "folder", "url": "report/ieic12.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI23", "leaf": true, "cls": "folder", "url": "report/ieid12.htm" 
			},
		]},{ "text": "Graduate teaching assistants are competent as classroom instructors", "id": "iei13", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IEI24", "leaf": true, "cls": "folder", "url": "report/ieic13.htm" 
		},
		{"text": "Degree Program Trend", "id": "IEI25", "leaf": true, "cls": "folder", "url": "report/ieid13.htm" 
			},
		]},
		
		] },
		{ "text": "Satisfaction", "id": 4011, "cls": "folder", "children": [
				{ "text": "The content of the course within my major is valuable", "id": "iesi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI01", "leaf": true, "cls": "folder", "url": "report/iesic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI02", "leaf": true, "cls": "folder", "url": "report/iesid1.htm" 
			},
		]},{ "text": "The instruction in my major field is excellent", "id": "iesi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI03", "leaf": true, "cls": "folder", "url": "report/iesic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI04", "leaf": true, "cls": "folder", "url": "report/iesid2.htm" 
			},
		]},{ "text": "Faculty are fair and unbiased in their treatment of individual students", "id": "iesi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ies05", "leaf": true, "cls": "folder", "url": "report/iesic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "IES06", "leaf": true, "cls": "folder", "url": "report/iesid3.htm" 
			},
		]},{ "text": "I am able to experience intellectual growth here", "id": "iesi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI07", "leaf": true, "cls": "folder", "url": "report/iesic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI08", "leaf": true, "cls": "folder", "url": "report/iesid4.htm" 
			},
		]},{ "text": "There is a commitment to academic excellence on this campus", "id": "iesi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI09", "leaf": true, "cls": "folder", "url": "report/iesic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI10", "leaf": true, "cls": "folder", "url": "report/iesid5.htm" 
			},
		]},{ "text": "Faculty provide timely feedback about student progress in a course", "id": "iesi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI11", "leaf": true, "cls": "folder", "url": "report/iesic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI12", "leaf": true, "cls": "folder", "url": "report/iesid6.htm" 
			},
		]},{ "text": "Faculty take into consideration student differences as they teach a course", "id": "iesi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI13", "leaf": true, "cls": "folder", "url": "report/iesic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI14", "leaf": true, "cls": "folder", "url": "report/iesid7.htm" 
			},
		]},{ "text": "The quality of instruction I recieve in most of my classes is excellent", "id": "iesi8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI15", "leaf": true, "cls": "folder", "url": "report/iesic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI16", "leaf": true, "cls": "folder", "url": "report/iesid8.htm" 
			},
		]},{ "text": "Adjunct faculty are competent as classroom instructors", "id": "iesi9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI17", "leaf": true, "cls": "folder", "url": "report/iesic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI18", "leaf": true, "cls": "folder", "url": "report/iesid9.htm" 
			},
		]},{ "text": "Faculty are usually available after class and during office hours", "id": "iesi10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI19", "leaf": true, "cls": "folder", "url": "report/iesic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI20", "leaf": true, "cls": "folder", "url": "report/iesid10.htm" 
			},
		]},{ "text": "Nearly all of the faculty are knowledgeable in their field", "id": "iesi11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI20", "leaf": true, "cls": "folder", "url": "report/iesic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI21", "leaf": true, "cls": "folder", "url": "report/iesid11.htm" 
			},
		]},{ "text": "There is a good variety of courses offered on this campus", "id": "iesi12", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI22", "leaf": true, "cls": "folder", "url": "report/iesic12.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI23", "leaf": true, "cls": "folder", "url": "report/iesid12.htm" 
			},
		]},{ "text": "Graduate teaching assistants are competent as classroom instructors", "id": "iesi13", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "IESI24", "leaf": true, "cls": "folder", "url": "report/iesic13.htm" 
		},
		{"text": "Degree Program Trend", "id": "IESI25", "leaf": true, "cls": "folder", "url": "report/ieisd13.htm" 
			},
		]},
		
		] },
		]},{"text": "Recruitment and Financial Aid", "id": 110, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4014, "cls": "folder", "children": [
		{ "text": "Admissions staff are knowledgeable", "id": "rfi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFI01", "leaf": true, "cls": "folder", "url": "report/rfic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFI02", "leaf": true, "cls": "folder", "url": "report/rfid1.htm" 
			},
		]},{ "text": "Admission counselors respond to prospective students' unique requests", "id": "rfi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFI03", "leaf": true, "cls": "folder", "url": "report/rfic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFI04", "leaf": true, "cls": "folder", "url": "report/rfid2.htm" 
			},
		]},{ "text": "Admissions counselors accurately portray the campus in their recruiting practics", "id": "rfi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "rf05", "leaf": true, "cls": "folder", "url": "report/rfic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "RF06", "leaf": true, "cls": "folder", "url": "report/rfid3.htm" 
			},
		]},{ "text": "Financial aid counselors are helpful", "id": "rfi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFI07", "leaf": true, "cls": "folder", "url": "report/rfic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFI08", "leaf": true, "cls": "folder", "url": "report/rfid4.htm" 
			},
		]},{ "text": "Financial aid awards are announced to students in time to be helpful in college planning", "id": "rfi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFI09", "leaf": true, "cls": "folder", "url": "report/rfic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFI10", "leaf": true, "cls": "folder", "url": "report/rfid5.htm" 
			},
		]},{ "text": "Adequate Financial aid is available for most students", "id": "rfi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFI11", "leaf": true, "cls": "folder", "url": "report/rfic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFI12", "leaf": true, "cls": "folder", "url": "report/rfid6.htm" 
			},
		]},
		
		] },
		{ "text": "Satisfaction", "id": 4015, "cls": "folder", "children": [
				{ "text": "Admissions staff are knowledgeable", "id": "rfsi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFSI01", "leaf": true, "cls": "folder", "url": "report/rfsic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFSI02", "leaf": true, "cls": "folder", "url": "report/rfsid1.htm" 
			},
		]},{ "text": "Admission counselors respond to prospective students' unique requests", "id": "rfsi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFSI03", "leaf": true, "cls": "folder", "url": "report/rfsic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFSI04", "leaf": true, "cls": "folder", "url": "report/rfsid2.htm" 
			},
		]},{ "text": "Admissions counselors accurately portray the campus in their recruiting practics", "id": "rfsi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "rfS05", "leaf": true, "cls": "folder", "url": "report/rfsic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFS06", "leaf": true, "cls": "folder", "url": "report/rfsid3.htm" 
			},
		]},{ "text": "Financial aid counselors are helpful", "id": "rfsi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFSI07", "leaf": true, "cls": "folder", "url": "report/rfsic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFSI08", "leaf": true, "cls": "folder", "url": "report/rfsid4.htm" 
			},
		]},{ "text": "Financial aid awards are announced to students in time to be helpful in college planning", "id": "rfsi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFSI09", "leaf": true, "cls": "folder", "url": "report/rfsic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFSI10", "leaf": true, "cls": "folder", "url": "report/rfsid5.htm" 
			},
		]},{ "text": "Adequate Financial aid is available for most students", "id": "rfsi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RFSI11", "leaf": true, "cls": "folder", "url": "report/rfsic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "RFSI12", "leaf": true, "cls": "folder", "url": "report/rfsid6.htm" 
			},
		]},
		
		] },
		]},{"text": "Registration effectiveness", "id": 111, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4016, "cls": "folder", "children": [
		{ "text": "Billing policies are reasonable", "id": "rei1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI01", "leaf": true, "cls": "folder", "url": "report/reic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI02", "leaf": true, "cls": "folder", "url": "report/reid1.htm" 
			},
		]},{ "text": "The cashiers office is open during hours which are convenient", "id": "rei2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI03", "leaf": true, "cls": "folder", "url": "report/reic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI04", "leaf": true, "cls": "folder", "url": "report/reid2.htm" 
			},
		]},{ "text": "The personnel involved in registration are helpful", "id": "rei3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "re05", "leaf": true, "cls": "folder", "url": "report/reic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "RE06", "leaf": true, "cls": "folder", "url": "report/reid3.htm" 
			},
		]},{ "text": "I am able to register for classes I need with few conflicts", "id": "rei4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI07", "leaf": true, "cls": "folder", "url": "report/reic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI08", "leaf": true, "cls": "folder", "url": "report/reid4.htm" 
			},
		]},{ "text": "Class change (drop/add) policies are reasonable", "id": "rei5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI09", "leaf": true, "cls": "folder", "url": "report/reic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI10", "leaf": true, "cls": "folder", "url": "report/reid5.htm" 
			},
		]},
		] },
		{ "text": "Satisfaction", "id": 4017, "cls": "folder", "children": [
				{ "text": "Billing policies are reasonable", "id": "rei1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI01", "leaf": true, "cls": "folder", "url": "report/resic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI02", "leaf": true, "cls": "folder", "url": "report/resid1.htm" 
			},
		]},{ "text": "The cashiers office is open during hours which are convenient", "id": "rei2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI03", "leaf": true, "cls": "folder", "url": "report/resic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI04", "leaf": true, "cls": "folder", "url": "report/resid2.htm" 
			},
		]},{ "text": "The personnel involved in registration are helpful", "id": "rei3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "re05", "leaf": true, "cls": "folder", "url": "report/resic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "RE06", "leaf": true, "cls": "folder", "url": "report/resid3.htm" 
			},
		]},{ "text": "I am able to register for classes I need with few conflicts", "id": "rei4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI07", "leaf": true, "cls": "folder", "url": "report/resic4.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI08", "leaf": true, "cls": "folder", "url": "report/resid4.htm" 
			},
		]},{ "text": "Class change (drop/add) policies are reasonable", "id": "rei5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "REI09", "leaf": true, "cls": "folder", "url": "report/resic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "REI10", "leaf": true, "cls": "folder", "url": "report/resid5.htm" 
			},
		]},
		] },
		]},{"text": "Responsiveness to Diverse Populations", "id": 112, "leaf": false, "cls": "folder", "children": [
		{ "text": "Satisfaction", "id": 4019, "cls": "folder", "children": [
				{ "text": "Institution's commitment to part-time students", "id": "rdpsi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPSI01", "leaf": true, "cls": "folder", "url": "report/rdpsc1.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPSI02", "leaf": true, "cls": "folder", "url": "report/rdpsd1.htm" 
			},
		]},{ "text": "Institution's commitment to evening students", "id": "rdp2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPSI03", "leaf": true, "cls": "folder", "url": "report/rdps2.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPSI04", "leaf": true, "cls": "folder", "url": "report/rdps2.htm" 
			},
		]},{ "text": "Institution's commitment to older, returning students", "id": "rdps3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPS05", "leaf": true, "cls": "folder", "url": "report/rdpsc3.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPS06", "leaf": true, "cls": "folder", "url": "report/rdpsd3.htm" 
			},
		]},{ "text": "Institution's commitment to underrepresented populations", "id": "rdpsi4", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPSI07", "leaf": true, "cls": "folder", "url": "report/rdpsc4.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPSI08", "leaf": true, "cls": "folder", "url": "report/rdpsid4.htm" 
			},
		]},{ "text": "Institution's commitment to commuters", "id": "rdpsi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPSI09", "leaf": true, "cls": "folder", "url": "report/rdpsic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPSI10", "leaf": true, "cls": "folder", "url": "report/rdpsid5.htm" 
			},
		]},{ "text": "Institution's commitment to students with disabilities", "id": "rdpsi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "RDPSI11", "leaf": true, "cls": "folder", "url": "report/rdpsic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "RDPSI12", "leaf": true, "cls": "folder", "url": "report/rdpsid6.htm" 
			},
		]},
		] },
		]},{"text": "Service Excellence", "id": 113, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4022, "cls": "folder", "children": [
		{ "text": "I seldom get the 'run-around' when seeking information on this campus", "id": "sexi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEXI01", "leaf": true, "cls": "folder", "url": "report/sexc1.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEXI02", "leaf": true, "cls": "folder", "url": "report/sexd1.htm" 
			},
		]},{ "text": "I generally know what's happening on campus", "id": "sex2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEXI03", "leaf": true, "cls": "folder", "url": "report/sexc2.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEXI04", "leaf": true, "cls": "folder", "url": "report/sexdc2.htm" 
			},
		]},{ "text": "The staff in the health service area are competent", "id": "sex3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEX05", "leaf": true, "cls": "folder", "url": "report/sexc3.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEX06", "leaf": true, "cls": "folder", "url": "report/sexd3.htm" 
			},
		]},
		] },
		{ "text": "Satisfaction", "id": 4021, "cls": "folder", "children": [
				{ "text": "I seldom get the 'run-around' when seeking information on this campus", "id": "sexsi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEXSI01", "leaf": true, "cls": "folder", "url": "report/sexsc1.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEXSI02", "leaf": true, "cls": "folder", "url": "report/sexsd1.htm" 
			},
		]},{ "text": "I generally know what's happening on campus", "id": "sexs2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEXSI03", "leaf": true, "cls": "folder", "url": "report/sexsc2.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEXSI04", "leaf": true, "cls": "folder", "url": "report/sexsdc2.htm" 
			},
		]},{ "text": "The staff in the health service area are competent", "id": "sexs3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "SEXS05", "leaf": true, "cls": "folder", "url": "report/sexsc3.htm" 
		},
		{"text": "Degree Program Trend", "id": "SEXS06", "leaf": true, "cls": "folder", "url": "report/sexsd3.htm" 
			},
		]},
		] },
		]},{"text": "Other Items", "id": 114, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4024, "cls": "folder", "children": [
		{ "text": "The assessment and course placement procedures are reasonable", "id": "oii1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "OII01", "leaf": true, "cls": "folder", "url": "report/oic1.htm" 
		},
		{"text": "Degree Program Trend", "id": "OII02", "leaf": true, "cls": "folder", "url": "report/oid1.htm" 
			},
		]},{ "text": "On the whole, the campus is well maintained", "id": "oi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "OII03", "leaf": true, "cls": "folder", "url": "report/oic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "OII04", "leaf": true, "cls": "folder", "url": "report/oidc2.htm" 
			},
		]},
		] },
		{ "text": "Satisfaction", "id": 4025, "cls": "folder", "children": [
				
		{ "text": "The assessment and course placement procedures are reasonable", "id": "oisi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "OISI01", "leaf": true, "cls": "folder", "url": "report/oisc1.htm" 
		},
		{"text": "Degree Program Trend", "id": "OISI02", "leaf": true, "cls": "folder", "url": "report/oisd1.htm" 
			},
		]},{ "text": "On the whole, the campus is well maintained", "id": "ois2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "OISI03", "leaf": true, "cls": "folder", "url": "report/oisc2.htm" 
		},
		{"text": "Degree Program Trend", "id": "OISI04", "leaf": true, "cls": "folder", "url": "report/oisdc2.htm" 
			},
		]},
		] },
		]},{"text": "ERAU Specific Items", "id": 115, "leaf": false, "cls": "folder", "children": [
		{ "text": "Importance", "id": 4026, "cls": "folder", "children": [
		{ "text": "ERAU treatment of students is fair and unbiased regardless of race and gender", "id": "esii1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI01", "leaf": true, "cls": "folder", "url": "report/esic1.htm" 
		},{"text": "Degree Program Trend", "id": "ESI02", "leaf": true, "cls": "folder", "url": "report/esid1.htm" 
			},
		]},{ "text": "There is an adequate selection of courses I want offered at times I can take them ", "id": "esii2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI03", "leaf": true, "cls": "folder", "url": "report/esic2.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI04", "leaf": true, "cls": "folder", "url": "report/esid2.htm" 
			},
		]},{ "text": "Class sizes are appropriate relative to types of courses. ", "id": "esii3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI05", "leaf": true, "cls": "folder", "url": "report/esic3.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI06", "leaf": true, "cls": "folder", "url": "report/esid3.htm" 
			},
		]},{ "text": "The quality of instruction during summer terms is similar to that of fall and spring terms ", "id": "esii5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI09", "leaf": true, "cls": "folder", "url": "report/esic5.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI10", "leaf": true, "cls": "folder", "url": "report/esid5.htm" 
			},
		]},{ "text": "The quality of the ERAU College catalog and admission publication is excellent", "id": "esii6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI11", "leaf": true, "cls": "folder", "url": "report/esic6.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI12", "leaf": true, "cls": "folder", "url": "report/esid6.htm" 
			}
		]},{ "text": "International Student Services meet the needs of international students.", "id": "esii7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI13", "leaf": true, "cls": "folder", "url": "report/esic7.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI14", "leaf": true, "cls": "folder", "url": "report/esid7.htm" 
			},
		]},{ "text": "Career Services is helpful in preparing me to search for a job upon completion of studies at ERAU", "id": "esii8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI15", "leaf": true, "cls": "folder", "url": "report/esic8.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI16", "leaf": true, "cls": "folder", "url": "report/esid8.htm" 
			},
		]},{ "text": "The services of the Student Employment Office adequately meets my employment needs", "id": "esii9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI17", "leaf": true, "cls": "folder", "url": "report/esic9.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI18", "leaf": true, "cls": "folder", "url": "report/esid9.htm" 
			},
		]},{ "text": "Flight training department policies help prepare me for the real world ", "id": "esii10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI19", "leaf": true, "cls": "folder", "url": "report/esic10.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI20", "leaf": true, "cls": "folder", "url": "report/esid10.htm" 
			},
		]},{ "text": "Generally, flight dispatcher serve me in a timely and polite manner ", "id": "esii11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESI21", "leaf": true, "cls": "folder", "url": "report/esic11.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESI22", "leaf": true, "cls": "folder", "url": "report/esid11.htm" 
			},
		]},
		
		] },
		{ "text": "Satisfaction", "id": 4027, "cls": "folder", "children": [
				
		{ "text": "ERAU treatment of students is fair and unbiased regardless of race and gender", "id": "esisi1", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS01", "leaf": true, "cls": "folder", "url": "report/esisc1.htm" 
		},{"text": "Degree Program Trend", "id": "ESIS02", "leaf": true, "cls": "folder", "url": "report/esisd1.htm" 
			},
		]},{ "text": "There is an adequate selection of courses I want offered at times I can take them ", "id": "esisi2", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS03", "leaf": true, "cls": "folder", "url": "report/esisc2.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS04", "leaf": true, "cls": "folder", "url": "report/esisd2.htm" 
			},
		]},{ "text": "Class sizes are appropriate relative to types of courses. ", "id": "esisi3", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS05", "leaf": true, "cls": "folder", "url": "report/esisc3.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS06", "leaf": true, "cls": "folder", "url": "report/esisd3.htm" 
			},
		]},{ "text": "The quality of instruction during summer terms is similar to that of fall and spring terms ", "id": "esisi5", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS09", "leaf": true, "cls": "folder", "url": "report/esisc5.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS10", "leaf": true, "cls": "folder", "url": "report/esisd5.htm" 
			},
		]},{ "text": "The quality of the ERAU College catalog and admission publication is excellent", "id": "esidi6", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS11", "leaf": true, "cls": "folder", "url": "report/esisc6.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS12", "leaf": true, "cls": "folder", "url": "report/esisd6.htm" 
			},
		]},{ "text": "International Student Services meet the needs of international students.", "id": "esisi7", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS13", "leaf": true, "cls": "folder", "url": "report/esisc7.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS14", "leaf": true, "cls": "folder", "url": "report/esisd7.htm" 
			},
		]},{ "text": "Career Services is helpful in preparing me to search for a job upon completion of studies at ERAU", "id": "esisi8", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS15", "leaf": true, "cls": "folder", "url": "report/esisc8.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS16", "leaf": true, "cls": "folder", "url": "report/esisd8.htm" 
			},
		]},{ "text": "The services of the Student Employment Office adequately meets my employment needs", "id": "esisi9", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS17", "leaf": true, "cls": "folder", "url": "report/esisc9.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS18", "leaf": true, "cls": "folder", "url": "report/esisd9.htm" 
			},
		]},{ "text": "Flight training department policies help prepare me for the real world ", "id": "esisi10", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS19", "leaf": true, "cls": "folder", "url": "report/esisc10.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS20", "leaf": true, "cls": "folder", "url": "report/esisd10.htm" 
			},
		]},{ "text": "Generally, flight dispatcher serve me in a timely and polite manner ", "id": "esisi11", "cls": "folder", "children": [
		{ "text": "Campus Trend", "id": "ESIS21", "leaf": true, "cls": "folder", "url": "report/esisc11.htm" 
		},
		{"text": "Degree Program Trend", "id": "ESIS22", "leaf": true, "cls": "folder", "url": "report/esisd11.htm" 
			},
		]},
		
		] },
		]},
		]},
		{ "text": "Fall 2006", "id": "ir1002", "leaf": true, "cls": "folder", "url": "2006/index.htm"
		},
		{ "text": "Fall 2004", "id": "cl20031", "leaf": true, "cls": "folder", "url": "2004/index.htm"
		},
		{ "text": "Fall 2002", "id": "cl20032", "leaf": true, "cls": "folder", "url": "2002/index.htm"
		},
		{ "text": "Fall 2000", "id": "cl20033", "leaf": true, "cls": "folder", "url": "2000/index.htm"
		},
		{ "text": "Fall 1998", "id": "cl20034", "leaf": true, "cls": "folder", "url": "1998/index.htm"
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
			title: 'SSI Survey',
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