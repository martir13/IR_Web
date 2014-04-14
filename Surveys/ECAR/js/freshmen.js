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
		}, { "text": "Most Recent Survey Instrument", "id": "h1001", "leaf": true, "cls": "folder", "url": "SurveyInstrument/index.htm", "html": "Amit, Amit"
		}, { "text": "Most Recent IR Preview", "id": "h1002", "leaf": true, "cls": "folder", "url": "IRPreview/index.htm", "html": "Amit, Amit"
		}]
		
		},
		{ "text": "Fall 2009", "id": 2000, "cls": "folder", "children": [
		
		{ "text": "Overview", "id": "s1000", "leaf": true, "cls": "folder", "url": "2009/index.htm", "html": "Amit, Amit"
		},{ "text": "Survey Instrument", "id": "s1002", "leaf": true, "cls": "folder", "url": "2009/surveyinstrument.htm", "html": "Amit, Amit"
		}, { "text": "IR Preview", "id": "s1003", "leaf": true, "cls": "folder", "url": "2009/irpreview.htm", "html": "Amit, Amit"
		}, { "text": "Attendance Decision", "id": 103, "expanded": false, "leaf": false, "cls": "folder", "children": [
		{ "text": "During your college decision and preparation activities, how would you rate your interactions with the following ERAU services?", "id": "e1000", "leaf": true, "cls": "folder", "url": "2009/During your college decision and preparation activities, how would you rate your interactions with the following ERAU services.swf", "html": "Amit, Amit"
		}, { "text": "How important was each factor in your major-selection decision?", "id": "e1001", "leaf": true, "cls": "folder", "url": "2009/How important was each factor in your major selection decison.swf"
},{ "text": "How important was each reason in your decision to come to ?", "id": "e1004", "leaf": true, "cls": "folder", "url": "2009/How important was each reason in your decision to come to ERAU.swf"
},{ "text": "How knowledgeable do you feel about the major you selected?", "id": "e1005", "leaf": true, "cls": "folder", "url": "2009/How knowledeable do you feel about the major you selected.swf"
},{ "text": "I chose to attend this ERAU campus because of its location?", "id": "e1006", "leaf": true, "cls": "folder", "url": "2009/I chose to attend this ERAU campus because of its location.swf"
},{ "text": "I chose to attend this ERAU campus because of the degree programs offered here ?", "id": "e1007", "leaf": true, "cls": "folder", "url": "2009/I chose to attend this ERAU campus because of the degree programs offered here.swf"
},{ "text": "Is this college your ?", "id": "e1008", "leaf": true, "cls": "folder", "url": "2009/Is this college your.swf"
},{ "text": "The following reasons were very important in deciding to go to this particular college ?", "id": "e1009", "leaf": true, "cls": "folder", "url": "2009/The following reasons were very important in deciding to go to this particular college.swf"
},{ "text": "The following were very important in deciding to go to college ?", "id": "e1010", "leaf": true, "cls": "folder", "url": "2009/The following were very important in deciding to go to college.swf"
},{ "text": "To how many college other than this one did you apply for admission this year ?", "id": "e1013", "leaf": true, "cls": "folder", "url": "2009/To how many college other than this one did you apply for admission this year.swf"
},{ "text": "Were you accepted to your first choice college ?", "id": "e1011", "leaf": true, "cls": "folder", "url": "2009/Were you accepted to your first choice college.swf"
}]
		
		},{"text": "Expectations", "id": 101, "leaf": false, "cls": "folder", "children": [
		{ "text": "Objectives considered to be essential or very important ?", "id": "em1000", "leaf": true, "cls": "folder", "url": "2009/Objectives considered to be essential or very important.swf"
		}, { "text": "Student estimates very good chance that they will ?", "id": "em1001", "leaf": true, "cls": "folder", "url": "2009/Student estimates vert good chance that they will.swf"
}]
		}
		,{"text": "Plans for Financing", "id": 102, "leaf": false, "cls": "folder", "children": [
		{ "text": "Do you have any concern about your ability to finance your college education ?", "id": "db1000", "leaf": true, "cls": "folder", "url": "2009/Do you have any concern about your ability to finance your college education.swf"
		}, { "text": "How much of your first year's educational expenses do you expect to come from ?", "id": "db1001", "leaf": true, "cls": "folder", "url": "2009/How much of your first year's educational expenses do you expect to come from.swf"
}, { "text": "What is your best estimate of your parents income ? ", "id": "db1002", "leaf": true, "cls": "folder", "url": "2009/What is your best estimate of your parents income.swf"
}]
		}
,{"text": "The Student", "id": 104, "leaf": false, "cls": "folder", "children": [
		{ "text": "During the past year did you frequently or occasionally ? ", "id": "pc1000", "leaf": true, "cls": "folder", "url": "2009/During the past year did you frequently or occasionally.swf"
		}, { "text": "During the past year did you frequently ?", "id": "pc1001", "leaf": true, "cls": "folder", "url": "2009/During the past year did you frequently.swf"
}, { "text": "During your last year in high school, how much time did you spend during the typical week doing the following activity ?", "id": "pc1002", "leaf": true, "cls": "folder", "url": "2009/During your last year in high school, how much time did you spend during the typical week doing the following activity.swf"
},{ "text": "Have you ever participated in flying lessons or a flight club ? ", "id": "pc1003", "leaf": true, "cls": "folder", "url": "2009/Have you ever participated in flying lessons or a flight club.swf"
		}, { "text": "High school I last attended: racial composition ?", "id": "pc1004", "leaf": true, "cls": "folder", "url": "2009/High school I last attended racial composition.swf"
}, { "text": "How important is it to you personally to become an active participant in aviation-aerospace ?", "id": "pc1005", "leaf": true, "cls": "folder", "url": "2009/How important is it to you personally to become an active participant in aviation-aerospace.swf"
},{ "text": "How would you characterize your poltical views ? ", "id": "pc1006", "leaf": true, "cls": "folder", "url": "2009/How would you characyerize your poltical views.swf"
		}, { "text": "Is your father and-or mother employed in the aviation-aerospace industry ", "id": "pc1007", "leaf": true, "cls": "folder", "url": "2009/Is your father and-or mother employed in the aviation-aerospace industry.swf"
}, { "text": "Neighborhood where I grew up: racial composition ", "id": "pc1008", "leaf": true, "cls": "folder", "url": "2009/Neighborhood where I grew up racial composition.swf"
},{ "text": "Percent noting english as a second language", "id": "pc1009", "leaf": true, "cls": "folder", "url": "2009/Percent noting english as a second language.swf"
		}, { "text": "Social Issues-Students agree Strongly or agree somewhat", "id": "pc1010", "leaf": true, "cls": "folder", "url": "2009/Social Issues-Students agree Strongly or agree somewhat.swf"
}, { "text": "Student rated self as highest 10% or above as compared with the average person their age ", "id": "pc1011", "leaf": true, "cls": "folder", "url": "2009/Student rated self as jighest 10% or above as compared with the average person their age.swf"
}, { "text": "What was your average grade in high school ? ", "id": "pc1011", "leaf": true, "cls": "folder", "url": "2009/What was your average grade in high school.swf"
}]
		
		}]
		},{"text": "Fall 2007 Administration ", "id": "ar1001", "leaf": false, "cls": "folder", "children": [
		{ "text": "Description", "id": "ar051000", "leaf": true, "cls": "folder", "url": "2007/description.htm"
		},{ "text": "Survey Instrument", "id": "ar051001", "leaf": true, "cls": "folder", "url": "2007/surveyinstrument.htm"
		},{ "text": "IR Preview", "id": "ar051002", "leaf": true, "cls": "folder", "url": "2007/irpreview.htm"
		},{ "text": "Introduction, Executive Summary, Methodology &amp; Response Rates", "id": "ar051003", "leaf": true, "cls": "folder", "url": "2007/introduction.htm"
		},{ "text": "The Students", "id": "ar051004", "leaf": true, "cls": "folder", "url": "2007/students.htm"
		},{ "text": "The College Attendance Decision", "id": "ar051005", "leaf": true, "cls": "folder", "url": "2007/collegeattendance.htm"
		},{ "text": "Selection of Career and Major", "id": "ar051006", "leaf": true, "cls": "folder", "url": "2007/selection_career.htm"
		},{ "text": "Plan for Financing College", "id": "ar051007", "leaf": true, "cls": "folder", "url": "2007/plan.htm"
		},{ "text": "Expectations for College and Beyond", "id": "ar051008", "leaf": true, "cls": "folder", "url": "2007/expectation_college.htm"
		},{ "text": "Data Tables", "id": "ar051009", "leaf": true, "cls": "folder", "url": "2007/datatables.htm"
		}]
		},
		{ "text": "Fall 2003", "id": "ir1002", "leaf": true, "cls": "folder", "url": "2003/index.htm"
		},
		{ "text": "Fall 2001", "id": "cl20031", "leaf": true, "cls": "folder", "url": "2001/index.htm"
		},
		{ "text": "Fall 1999", "id": "cl20021", "leaf": true, "cls": "folder", "url": "1999/index.htm"
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
			title: 'Freshmen Survey',
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