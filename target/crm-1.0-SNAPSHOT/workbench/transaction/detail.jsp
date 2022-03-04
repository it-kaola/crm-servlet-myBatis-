<%@ page import="java.util.List" %>
<%@ page import="com.bjpowernode.crm.settings.domain.DicValue" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.bjpowernode.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	/*
	上面这条语句得到的结果是：basePath=http://127.0.0.1:8080/crm/
	*/

	// 从应用域中取出stage的字典值
	List<DicValue> dicValueList = (List<DicValue>) application.getAttribute("stageList");

	// 从应用域中取出stage和possibility对应关系的map集合
	Map<String, String> pMap = (Map<String, String>) application.getAttribute("pMap");

	// 从pMap中取出所有的key值
	Set<String> set = pMap.keySet();

	// 计算出正常阶段和丢失阶段的分界点下标
	int point = 0;
	for(int i=0; i<dicValueList.size(); i++){
		// 取出字典值列表中的每一个字典值
		DicValue dicValue = dicValueList.get(i);
		// 每个dicValue对象中的value属性就是stage
		String stage = dicValue.getValue();
		// 根据stage得到possibility
		String possibility = pMap.get(stage);
		if("0".equals(possibility)){
			// 如果possibility为0，说明到达了正常阶段和丢失阶段的分界点，将当前下标赋值给point，结束循环
			point = i;
			break;
		}
	}


%>


<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

	<style type="text/css">
	.mystage{
		font-size: 20px;
		vertical-align: middle;
		cursor: pointer;
	}
	.closingDate{
		font-size : 15px;
		cursor: pointer;
		vertical-align: middle;
	}
	</style>

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

	<script type="text/javascript">

		//默认情况下取消和保存按钮是隐藏的
		var cancelAndSaveBtnDefault = true;

		$(function(){
			$("#remark").focus(function(){
				if(cancelAndSaveBtnDefault){
					//设置remarkDiv的高度为130px
					$("#remarkDiv").css("height","130px");
					//显示
					$("#cancelAndSaveBtn").show("2000");
					cancelAndSaveBtnDefault = false;
				}
			});

			$("#cancelBtn").click(function(){
				//显示
				$("#cancelAndSaveBtn").hide();
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","90px");
				cancelAndSaveBtnDefault = true;
			});

			$(".remarkDiv").mouseover(function(){
				$(this).children("div").children("div").show();
			});

			$(".remarkDiv").mouseout(function(){
				$(this).children("div").children("div").hide();
			});

			$(".myHref").mouseover(function(){
				$(this).children("span").css("color","red");
			});

			$(".myHref").mouseout(function(){
				$(this).children("span").css("color","#E6E6E6");
			});


			//阶段提示框
			$(".mystage").popover({
				trigger:'manual',
				placement : 'bottom',
				html: 'true',
				animation: false
			}).on("mouseenter", function () {
						var _this = this;
						$(this).popover("show");
						$(this).siblings(".popover").on("mouseleave", function () {
							$(_this).popover('hide');
						});
					}).on("mouseleave", function () {
						var _this = this;
						setTimeout(function () {
							if (!$(".popover:hover").length) {
								$(_this).popover("hide")
							}
						}, 100);
					});

			// 在页面加载完毕后，展示交易历史列表
			showHistoryTranList()

		});

		// 展示交易历史列表
		function showHistoryTranList() {

			$.ajax({
				url : "workbench/transaction/getTranHistoryListByTranId.do",
				data : {"tranId" : "${transaction.id}"},
				type : "get",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 [{交易历史1}, {交易历史2}, .....]
					var html = "";
					$.each(respData, function (index, element) {
						html += '<tr>';
						html += '<td>'+ element.stage +'</td>';
						html += '<td>'+ element.money +'</td>';
						html += '<td>'+ element.possibility +'</td>';
						html += '<td>'+ element.expectedDate +'</td>';
						html += '<td>'+ element.createTime +'</td>';
						html += '<td>'+ element.createBy +'</td>';
						html += '</tr>';
					});
					// 向表格中填充数据
					$("#TranHistoryTBody").html(html);
				}
			});

		}


		// 改变状态
		function changeStage(index, stage) {
			// index 表示需要改变的阶段对应的下标
			// stage 表示需要改变的阶段

			// 发出ajax请求，局部刷新当前页面，也要改变的是当前页面的 阶段 可能性 修改人 修改时间 交易历史列表
 			$.ajax({
				url : "workbench/transaction/changeStage.do",
				data : {
					"id" : "${transaction.id}",
					"stage" : stage,
					"money" : "${transaction.money}",
					"expectedDate" : "${transaction.expectedDate}"
				},
				type : "post",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"isSuccess" : true/flase, "TranObj" : {id : xxx}} // 其中TranObj交易对象中应该要有 阶段 可能性 修改人 修改时间 这四个值
					if(respData.isSuccess){
						// 更新页面相应的值
						$("#stage").html(respData.TranObj.stage);
						$("#possibility").html(respData.TranObj.possibility);
						$("#editBy").html(respData.TranObj.editBy);
						$("#editTime").html(respData.TranObj.editTime);
						// 改变图标
						changeIcon(index, stage);
						// 展示新的交易历史表
						showHistoryTranList();
					}else{
						alert("更新交易状态失败");
					}
				}
			});
		}


		// 改变图标
		function changeIcon(currentIndex, currentStage){
			// 当前阶段对应的可能性
			var currentPossibility = $("#possibility").html();

			if(currentPossibility == "0"){
				// 如果当前阶段的可能性为0，前七个一定是黑圈，后面两个中一个是黑叉一个是红叉
				// 遍历前7个
				for(var i=0; i<<%=point%>; i++){
					// 黑圈
					// 移除掉原有的样式
					$("#"+i).removeClass();
					// 添加新样式
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					// 添加颜色
					$("#"+i).css("color", "black");

				}

				// 遍历后2个
				for(var i=<%=point%>; i<<%=dicValueList.size()%>; i++){
					if(currentIndex == i){
						// 红叉
						// 移除掉原有的样式
						$("#"+i).removeClass();
						// 添加新样式
						$("#"+i).addClass("glyphicon glyphicon-remove mystage");
						// 添加颜色
						$("#"+i).css("color", "red");

					}else{
						// 黑叉
						// 移除掉原有的样式
						$("#"+i).removeClass();
						// 添加新样式
						$("#"+i).addClass("glyphicon glyphicon-remove mystage");
						// 添加颜色
						$("#"+i).css("color", "black");

					}
				}

			}else{
				// 如果当前阶段的可能性不为0，前七个有的是绿钩，有的是绿色标记，有的是黑圈，后面两个一定是黑叉
				// 遍历前7个
				for(var i=0; i<<%=point%>; i++){
					if(i<currentIndex){
						// 绿钩
						// 移除掉原有的样式
						$("#"+i).removeClass();
						// 添加新样式
						$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
						// 添加颜色
						$("#"+i).css("color", "#90F790");

					}else if(i == currentIndex){
						// 绿色标记
						// 移除掉原有的样式
						$("#"+i).removeClass();
						// 添加新样式
						$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
						// 添加颜色
						$("#"+i).css("color", "#90F790");

					}else{
						// 黑圈
						// 移除掉原有的样式
						$("#"+i).removeClass();
						// 添加新样式
						$("#"+i).addClass("glyphicon glyphicon-record mystage");
						// 添加颜色
						$("#"+i).css("color", "black");

					}
				}

				// 遍历后2个
				for(var i=<%=point%>; i<<%=dicValueList.size()%>; i++){
					// 黑叉
					// 移除掉原有的样式
					$("#"+i).removeClass();
					// 添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					// 添加颜色
					$("#"+i).css("color", "black");
				}

			}
		}

	</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${transaction.customerId}-${transaction.name} <small>￥${transaction.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.jsp';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
			// 获取当前阶段
			String currentStage = ((Tran) request.getAttribute("transaction")).getStage();
			// 获取当前可能性
			String possibility = (String) request.getAttribute("possibility");

			// 先判断当前阶段的可能性
			if("0".equals(possibility)){
				// 如果当前阶段的可能性为0，前7个状态一定是黑圈，后面两个有一个是红叉，一个是黑叉
				for(int i=0; i<dicValueList.size(); i++){
					DicValue dicValue = dicValueList.get(i);
					// 遍历出每个dicValue对象的阶段和其对应的可能性
					String iterStage = dicValue.getValue();
					String iterPossibility = pMap.get(iterStage);
					if("0".equals(iterPossibility)){
						// 如果当前迭代的possibility的值为0，说明当前已经到了交易失败的阶段，接下来要判断哪个需要变成红叉
						if(iterStage.equals(currentStage)){
							// 如果遍历的阶段与当前阶段的值相同，说明要填充红叉
							// 红叉
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: red;"></span>
							-----------
		<%
						}else{
							// 黑叉
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: black;"></span>
							-----------
		<%
						}

					}else{
						// 程序能够执行到此处说明当前迭代的possibility的值不为0(大前提是当前阶段的可能性为0)，应该填充黑圈
						// 黑圈
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: black;"></span>
							-----------
		<%
					}
				}

			}else{
				// 如果当前阶段的可能性不为0，前7个有可能是绿钩或绿色标记或黑圈，但后面两个一定是黑叉

				// 获取当前阶段的下标
				int index = 0;
				for(int i=0; i<dicValueList.size(); i++){
					DicValue dicValue = dicValueList.get(i);
					// 遍历出每个dicValue对象的阶段和其对应的可能性
					String iterStage = dicValue.getValue();
					if(iterStage.equals(currentStage)){
						index = i;
						break;
					}
				}

				for(int i=0; i<dicValueList.size(); i++){
					DicValue dicValue = dicValueList.get(i);
					// 遍历出每个dicValue对象的阶段和其对应的可能性
					String iterStage = dicValue.getValue();
					String iterPossibility = pMap.get(iterStage);
					if("0".equals(iterPossibility)){
						// 如果当前迭代的possibility的值为0，说明当前已经到了交易失败的阶段，此时一定都是黑叉
						// 黑叉
		%>
						<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: black;"></span>
						-----------
		<%
					}else{
						// 程序能够执行到此处说明当前迭代的possibility的值不为0(大前提是当前阶段的可能性不为0)，判断一下前面7个的图标
						if(i < index){
							// 应该填充绿钩
							// 绿钩
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
							-----------
		<%
						}else if(i == index){
							// 应该填充绿色标记
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
							-----------
		<%
						}else{
							// 应该填充黑圈
		%>
							<span id="<%=i%>" onclick="changeStage('<%=i%>', '<%=iterStage%>')" class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: black;"></span>
							-----------
		<%
						}
					}
				}
			}
		%>
		<%--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>
		-----------
		<span class="closingDate">${transaction.expectedDate}</span>--%>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.customerId}-${transaction.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${transaction.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${transaction.possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transaction.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transaction.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${transaction.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${transaction.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;" id="editTime">${transaction.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${transaction.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${transaction.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
 			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transaction.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="TranHistoryTBody">
						<%--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>