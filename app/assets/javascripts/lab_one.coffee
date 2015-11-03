# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	Numiration()

	$('#regular-minus').click ->
		if $('#tableId table').find('tr:first-child').find('td').length > 4
			AddColumn('minus')

	$('#regular-plus').click ->
		AddColumn('plus')

	$('#start').click ->
		$("#placeholder-wrapper").show 800
		data = []
		arrayLength = $('#tableId table').find('tr:first-child').find('td').length - 1
		i = 1
		while i <= arrayLength
			x = ($('[data-id=1'+i+']').val() * 1)
			y = ($('[data-id=2'+i+']').val() * 1)
			data.push [x,y]
			i++
		CreateChart(data)


#------------------------------------------------------------------------------------
AddColumn = (handler) ->
	if handler == "plus"
		$('#tableId table tr').each ->
			$(this).append '<td></td>'
			return
	else
		$('#tableId table tr').each ->
			$(this).find("td:last-child").remove()
			return
	Numiration()

Numiration = () ->
	i = 0
	$('#tableId table').find('tr:first-child').find('td').each ->
		if i > 0
			$(this).html i
		i++
	i = 0
	$('#tableId table').find('tr:last-child').find('td').each ->
		if i > 0
			handler = "2" + i.toString()
			$(this).html '<input data-id =' + handler + ' class="input-table" type="text">'
		i++
	i = 0
	$('#tableId table').find('tr:nth-child(2)').find('td').each ->
		if i > 0
			handler = "1" + i.toString()
			$(this).html '<input data-id =' + handler + ' class="input-table" type="text">'
		i++

	return

CreateChart = (data) ->
	minX = data[0][0]
	maxX = data[0][0]
	minY = data[0][1]
	maxY = data[0][1]
	handler = 0

	while handler < data.length - 1
		minX = data[handler + 1][0] if data[handler + 1][0] < minX
		minY = data[handler + 1][1] if data[handler + 1][1] < minY
		maxX = data[handler + 1][0] if data[handler + 1][0] > maxX
		maxY = data[handler + 1][1] if data[handler + 1][1] > maxY
		handler++

		hX = (maxX - minX) / 10.00
		hY = (maxY - minY) / 10.00


	handler = 0
	dataX = []
	dataY = []
	dataXY = []
	dataXMiddle = 0
	dataYMiddle = 0

	while handler < data.length
		dataX.push data[handler][0]
		dataY.push data[handler][1]
		dataXMiddle += data[handler][0]
		dataYMiddle += data[handler][1]
		dataXY.push (data[handler][0] * data[handler][1])
		handler++
	
	n = data.length
	dataXMiddle = dataXMiddle / n
	dataYMiddle = dataYMiddle / n
	dataXSumm = GetSumm(dataX)
	dataYSumm = GetSumm(dataY)
	dataXYSumm = GetSumm(dataXY)
	dataXSummPow = GetSumm(dataX,true)
	dataYSummPow = GetSumm(dataY,true)

	a = GetParamsA(dataXSumm,dataYSumm,dataXSummPow,dataYSummPow,dataXYSumm,n) 
	b = GetParamsB(dataXSumm,dataYSumm,dataXSummPow,dataYSummPow,dataXYSumm,n) 
	r = GetR(dataXMiddle, dataYMiddle,dataXSummPow,dataYSummPow,dataXYSumm,n)
	
	$('#output-r').val r
	if r < 0.7
		color = "rgba(255, 112, 77, 0.6)"
	else
		color = "rgba(0, 227, 0, 0.6)"

	$('#output-r').css
		backgroundColor: color		

	dataLines = []
	dataLines.push [
		minX
		GetY(minX,a,b)
	]
	dataLines.push [
		maxX
		GetY(maxX,a,b)
	]

	options = 

		grid:
			borderColor: '#507296'
			hoverable: true

		yaxis:
			min: minY - hY 
			max: maxY + hY
			tickSize: hY

		xaxis:
			min: minX - hX 
			max: maxX + hX
			tickSize: hX

	$.plot $("#placeholder"), [ 
		{
			data: data
			lines: show: false
			points: 
				show: true
		}
		{
			data: dataLines
			lines: show: true
			points: 
				show: false
		}
	], options  

	$("#placeholder").UseTooltip()

GetParamsA = (xSumm,ySumm,xSummPow,ySummPow,xySumm,n) ->
	return ((ySumm * xSummPow)-(xySumm * xSumm))/(n * xSummPow - (xSumm * xSumm))

GetParamsB = (xSumm,ySumm,xSummPow,ySummPow,xySumm,n) ->
	return ((n * xySumm)-(xSumm * ySumm))/(n * xSummPow - (xSumm * xSumm))

GetY = (x,a,b) ->
	return b * x + a 

GetR = (xMiddle, yMiddle,xSummPow,ySummPow,xySumm, n) ->
	return Math.abs((xySumm - (n * xMiddle * yMiddle)) / (Math.sqrt((xSummPow - (n * (xMiddle * xMiddle))) * (ySummPow - (n * (yMiddle * yMiddle)))))).toFixed(4)
	
GetSumm = (data, pow = false) ->
	handler = 0
	summ = 0
	while handler < data.length
		summ = summ + (data[handler] * data[handler]) if pow == true
		summ = summ + data[handler] if pow == false
		handler++
	return summ

$.fn.UseTooltip = ->
	previousPoint = null
	$(this).bind 'plothover', (event, pos, item) ->
		if item
			if previousPoint != item.dataIndex
				previousPoint = item.dataIndex
				$('#tooltip').remove()
				x = item.datapoint[0]
				y = item.datapoint[1]
				showTooltip item.pageX, item.pageY, '[' + x + ',' + y + ']'
		else
			$('#tooltip').remove()
			previousPoint = null
		return
	return


showTooltip = (x, y, contents) ->
	$('<div id="tooltip">' + contents + '</div>').css(
		position: 'absolute'
		display: 'none'
		top: y + 5
		left: x + 20
		padding: '5px'
		size: '10'
		backgroundColor: '#ABBAC9'
		borderRadius: '3px'
		opacity: 0.80).appendTo('body').fadeIn 200
	return
