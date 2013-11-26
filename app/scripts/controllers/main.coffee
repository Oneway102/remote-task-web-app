'use strict'

# TODO: Maybe we should move the cookie functions out of this file.
setCookie = (c_name,value,exdays) ->
  exdate = new Date();
  exdate.setDate(exdate.getDate() + exdays)
  c_value = escape(value) + if exdays? then "; expires=" + exdate.toUTCString() else ""
  document.cookie = c_name + "=" + c_value
  return

getCookie = (c_name) ->
  c_value = document.cookie
  c_start = c_value.indexOf(" " + c_name + "=")
  if c_start == -1
    c_start = c_value.indexOf(c_name + "=")
  if c_start == -1
    c_value = null
  else
    c_start = c_value.indexOf("=", c_start) + 1
    c_end = c_value.indexOf(";", c_start)
    if c_end == -1
      c_end = c_value.length;
    c_value = unescape(c_value.substring(c_start,c_end));
  return c_value

gMY_TOKEN = null
gMY_NAME = null
gMY_ID = null

getAuthCookie = () ->
  gMY_TOKEN = getCookie("smart_token")
  gMY_NAME = getCookie("smart_name")
  gMY_ID = parseInt(getCookie("smart_id"))

setAuthCookie = (id, name, token) ->
  setCookie("smart_token", token, 30)
  setCookie("smart_name", name, 30)
  setCookie("smart_id", id, 30)

getAuthCookie()


# Agular module definition begins here.

angular.module('angApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $http.get('/api/awesomeThings').success (awesomeThings) ->
      $scope.awesomeThings = awesomeThings

  .controller 'AppCtrl', ($scope, $http, $location) ->
    $scope.isLogin = () ->
      return if gMY_TOKEN? and gMY_NAME? and gMY_ID? then true else false
    $scope.getUserName = () ->
      return gMY_NAME
    $scope.logout = () ->
      setAuthCookie("", "", "")
      gMY_TOKEN = gMY_NAME = gMY_ID = null
      $location.path "/login"
      return

  .controller 'LoginCtrl', ($scope, $http, $cookies) ->
    $scope.loginForm = {}
    $scope.showMessage = false
    $scope.promptMessage = ""

    #gMY_TOKEN = getCookie("smart_token")
    #gMY_NAME = getCookie("smart_name")

    $scope.login = () ->
      return if not $scope.loginForm.email? or not $scope.loginForm.password?
      # Get token indeed
      data = 
        email: $scope.loginForm.email
        password: $scope.loginForm.password
      $http.post("api/auth/get_access_token", data)
        .success (data) ->
          # b054 - 9dd8a600-4d15-11e3-bfb6-cfebdcc7445f
          console.log "Token: " + data.access_token
          gMY_TOKEN = data.access_token
          gMY_ID = data.id
          gMY_NAME = $scope.loginForm.email
          setAuthCookie(gMY_ID, gMY_NAME, gMY_TOKEN)
          #$cookie.smart_token = data.access_token
          $scope.showMessage = true
          $scope.promptMessage = "Done: " + data.access_token
        .error (data, status, headers, config) ->
          # TODO: prompt
          return
        return
    $scope.register = () ->
      $http.post("api/users", $scope.loginForm)
        .success (data) ->
          data = 
            email: data.email
            password: $scope.loginForm.password
          $http.post("api/auth/get_access_token", data)
            .success (data) ->
              # b054 - 9dd8a600-4d15-11e3-bfb6-cfebdcc7445f
              console.log "Token: " + data.access_token
              gMY_TOKEN = data.access_token
              gMY_ID = data.id
              gMY_NAME = $scope.loginForm.email
              setAuthCookie(gMY_ID, gMY_NAME, gMY_TOKEN)
              #$cookie.smart_token = data.access_token
              $scope.showMessage = true
              $scope.promptMessage = "Done: " + data.access_token
            .error (data, status, headers, config) ->
              # TODO: prompt
              return
            return
        .error (data, status, headers, config) ->
          # TODO: prompt error
          $scope.error = data.error
          $scope.promptMessage = "Failed: " + data.error
          $scope.showMessage = true
      return
    $scope.showLogin = () ->
      return not gMY_TOKEN? or not gMY_NAME?
    return

  .controller 'WksCtrl', ($scope, $http) ->
    $http.get('api/workstations').success (data) ->
      $scope.zks = data
    return

  .controller 'DevicesCtrl', ($scope, $http) ->
    $scope.my_filter = {creator_id:gMY_ID}
    $http.get("api/devices?access_token=" + gMY_TOKEN).success (data) ->
      $scope.devices = data
      return
    $scope.getWkName = (device) ->
      return if device.workstation.name? then device.workstation.name else device.workstation.mac
    return

  .controller 'TasksCtrl', ($scope, $http) ->
    $scope.my_filter = {creator_id:gMY_ID} # default value for "my tasks";
    $scope.myId = gMY_ID
    $http.get("api/tasks?access_token=" + gMY_TOKEN).success (data) ->
      $scope.tasks = data
    #$scope.isMyTask = (expected, task) ->
    #  return $scope.myId == task.creator.id
    $scope.getProductInfo = (job) ->
      return "- / -" if not job.device_filter.product?
      brand = if job.device_filter.product.manufacturer? then job.device_filter.product.manufacturer else "-"
      product = if job.device_filter.product.model? then job.device_filter.product.model else "-"
      brand + " / " + product
    $scope.getWorkstation = (job) ->
      return "-" if not job.device_filter.mac?
      job.device_filter.mac
    $scope.getSerial = (job) ->
      return "-" if not job.device_filter.serial?
      job.device_filter.serial
    return

  .controller 'JobsCtrl', ($scope, $http) ->
    $http.get('api/jobs').success (data) ->
      #$scope.jobs = data
      # for debug only.
      $scope.jobs = [
        {
        id: 12
        task: "MTBF"
        start_time: 1364969756
        group: "Apple"
        tester: "b123"
        status: "running"
        }
        {
        id: 16
        task: "App_Test"
        start_time: 1364967756
        group: "Banana"
        tester: "b321"
        status: "failed"
        }
      ]
    return

  .controller 'AddTaskCtrl3', ($scope, $http, $location) ->
    # Some initialization.
    $scope.newTaskForm = {}
    $scope.newTaskForm.jobs = []
    #createJob()
    # Data used to show as HTML select options. Contents of [manufacturers] and [products] may change each time user makes a new selection.
    $scope.platforms = []
    # Available options
    $scope.displayedOptions = 
      platforms: []
      manufacturers: []
      models: []
      devices: []
    # Selected options
    $scope.selectedOptions = 
      platforms: []
      manufacturers: []
      models: {}
      devices: []
    # Filter var
    $scope.device_filter = 
      anyDevice: true

    # Retrieve the available devices first.
    $scope.devices = []
    $scope.manufacturers = $scope.models = []
    initDeviceOptions = () ->
      #$scope.platforms = groupPlatform()
      #$scope.deviceOptions.manufacturers = groupProductProperties("manufacturer")
      #$scope.deviceOptions.models = groupProductProperties("model")
      $scope.displayedOptions = ['android', 'tizen'] # fake data

    $http.get("api/devices?access_token=" + gMY_TOKEN).success (data) ->
      $scope.devices = data
      device._index = i for device, i in $scope.devices
      initDeviceOptions()

    $scope.selectPlatform = ($event) ->
      el = $event.target
      index = $scope.selectedOptions.platforms.indexOf(el.value)
      if el.checked is true
        $scope.selectedOptions.platforms.push(el.value) if index is -1
      else
        $scope.selectedOptions.platforms.splice(index, 1) if index >= 0
      # Update the optional manufacturer list.

      return

    $scope.selectManufacturer = ($event) ->
      el = $event.target
      index = $scope.selectedOptions.manufacturers.indexOf(el.value)
      if el.checked is true
        $scope.selectedOptions.manufacturers.push(el.value) if index is -1
      else
        $scope.selectedOptions.manufacturers.splice(index, 1) if index >= 0
      return

    $scope.manufacturerFilter = (device) ->
      #return if $scope.selectedOptions.platforms.indexOf(device.platform) isnt -1 then true else false
      if $scope.selectedOptions.platforms.indexOf(device.platform) is -1
        return false
      # Avoid duplicated options.
      if $scope.displayedOptions.manufacturers.indexOf(device.product.manufacturer) isnt -1
        return false
      $scope.displayedOptions.manufacturers.push(device.product.manufacturer)
      return true

    $scope.manufacturerGroup = () ->
      $scope.displayedOptions.manufacturers = []
      return $scope.devices

    $scope.selectModel = ($event, _deviceIndex) ->
      el = $event.target
      #index = $scope.selectedOptions.models.indexOf(el.value)
      if el.checked is true
        #$scope.selectedOptions.models.push({el.value: _deviceIndex}) if index is -1
        $scope.selectedOptions.models[el.value] = _deviceIndex
      else
        #$scope.selectedOptions.models.splice(index, 1) if index >= 0
        delete $scope.selectedOptions.models[el.value]
      return

    $scope.modelFilter = (device) ->
      #if $scope.selectedOptions.platforms.indexOf(device.platform) is -1
      #  return false
      if $scope.selectedOptions.manufacturers.indexOf(device.product.manufacturer) is -1
        return false
      # Avoid duplicated options.
      if $scope.displayedOptions.models.indexOf(device.product.model) isnt -1
        return false
      $scope.displayedOptions.models.push(device.product.model)
      return true

    $scope.modelGroup = () ->
      $scope.displayedOptions.models = []
      return $scope.devices

    $scope.selectDevice = ($event, _deviceIndex) ->
      el = $event.target
      if el.value is "anyDevice"
        return device_filter.anyDevice
      index = $scope.selectedOptions.devices.indexOf(_deviceIndex)
      if el.checked is true
        # Seems no duplicated options for now.
        $scope.selectedOptions.devices.push(_deviceIndex) if index is -1
      else
        $scope.selectedOptions.devices.splice(index, 1) if index >= 0
      return

    $scope.deviceFilter = (device) ->
      #if $scope.selectedOptions.platforms.indexOf(device.platform) is -1
      #  return false
      #if $scope.selectedOptions.manufacturers.indexOf(device.product.manufacturer) is -1
      #  return false
      if not $scope.selectedOptions.models[device.product.model]?
        return false
      # Avoid duplicated options. - ( But seems no duplicated devices for now.)
      return true

    $scope.deviceGroup = () ->
      $scope.displayedOptions.devices = []
      return $scope.devices

    $scope.objectLength = (obj) ->
      count = 0
      for oo of obj
        count++
      return count

    $scope.submitTask = () ->
      # Two cases depending on device_filter.anyDevice:
      #   1) true: generate jobs based on models;
      #   2) false: generate jobs based on devices.
      $scope.newTaskForm.jobs = []
      if $scope.device_filter.anyDevice is true
        iii = 0
        for m, index of $scope.selectedOptions.models
          device = $scope.devices[index]
          job = {
            #no: i
            r_type: $scope.newTaskForm.r_type
            device_filter:
              platform: device.platform
              product:
                manufacturer: device.product.manufacturer
                model: m
          }
          job.no = iii++
          $scope.newTaskForm.jobs.push(job)
      else
        # job by device
        for index, i in $scope.selectedOptions.devices
          device = $scope.devices[index]
          tokens = device.id.split("-")
          job = 
            #no: i
            r_type: $scope.newTaskForm.r_type
            device_filter:
              platform: device.platform
              product:
                mac: tokens[0]
                serial: tokens[1]
          job.no = i
          $scope.newTaskForm.jobs.push(job)

      $http.post("api/tasks?access_token=" + gMY_TOKEN, $scope.newTaskForm).success (data) ->
        $location.path "/jobs"
        return;
      return
    return


  .controller 'AddTaskCtrl2', ($scope, $http, $location) ->
    resort = () ->
      job.no = i for job, i in $scope.newTaskForm.jobs
      return
    createJob = () ->
      job = {}
      job.no = $scope.newTaskForm.jobs.length
      job.repo_url = $scope.newTaskForm.repo_url
      job.device_filter = {platform: "", manufacturer: "", model: ""}
      # Register some watchers on device selection.
      job.deviceOptions = 
        manufacturers: []
        models: []
        devices: []
      $scope.$watch('job.device_filter.platform', () ->
        if not job.device_filter.platform?
          return
          # Reset job.deviceOptions.manufacturers
        job.deviceOptions.manufacturer = []
        for d in $scope.devices
          # Filtered by platform.
          if d.platform isnt job.device_filter.platform
            continue
          if job.deviceOptions.manufacturer.indexOf(d.product.manufacturer) is -1
            job.deviceOptions.manufacturer.push(d.product.manufacturer)
      )
      $scope.$watch(job.device_filter.manufacturer, () ->
        if not job.device_filter.manufacturer?
          return
        job.deviceOptions.models = []
        for d in $scope.devices
          # Filtered by platform and manufacturer
          if d.platform isnt job.device_filter.platform
            continue
          if d.product.manufacturer isnt job.device_filter.manufacturer
            continue
          if job.deviceOptions.models.indexOf(d.product.model) is -1
            job.deviceOptions.models.push(d.product.model)
      )
      # Add the job to job list.
      $scope.newTaskForm.jobs.push(job)
      job
    removeJob = (index) ->
      return if index >= $scope.newTaskForm.jobs.length
      $scope.newTaskForm.jobs.splice(index, 1)
      resort()
      return
    # TODO: Use underscore.js
    groupPlatform = () ->
      result = []
      return result if $scope.devices.length is 0
      for d in $scope.devices
        if not d.platform?
          continue
        if result.indexOf(d.platform) is -1
          result.push(d.platform)
      result
    # TODO: Use underscore.js
    groupProductProperties = (key) ->
      result = []
      return result if $scope.devices.length is 0
      for d in $scope.devices
        #if d.product.hasOwnProperty(key) and d.product.
        if not d.product[key]?
          continue
        if result.indexOf(d.product[key]) == -1
          result.push(d.product[key])
      return result
    initDeviceOptions = () ->
      $scope.platforms = groupPlatform()
      #$scope.deviceOptions.manufacturers = groupProductProperties("manufacturer")
      #$scope.deviceOptions.models = groupProductProperties("model")

    # Some initialization.
    $scope.newTaskForm = {}
    $scope.newTaskForm.jobs = []
    #createJob()
    # Data used to show as HTML select options. Contents of [manufacturers] and [products] may change each time user makes a new selection.
    $scope.platforms = []

    # Retrieve the available devices first.
    $scope.devices = []
    $scope.manufacturers = $scope.models = []
    $http.get("api/devices?access_token=" + gMY_TOKEN).success (data) ->
      $scope.devices = data
      initDeviceOptions()

    # Triggered when user clicks the button to add a job in a task.
    $scope.newJob = () ->
      createJob()

    # Triggered when user clicks the button to remove an existing job in a task.
    $scope.deleteJob = (index) ->
      removeJob(index)

    # TODO: use underscore.js + Angular filter to group it.
    $scope.updateManufactures = (job) ->
      if not job.device_filter.platform?
        job.deviceOptions.manufacturers = []
        return
        # Reset job.deviceOptions.manufacturers
      job.deviceOptions.manufacturers = []
      for d in $scope.devices
        # Filtered by platform.
        if d.platform isnt job.device_filter.platform
          continue
        if job.deviceOptions.manufacturers.indexOf(d.product.manufacturer) is -1
          job.deviceOptions.manufacturers.push(d.product.manufacturer)
      return

    # TODO: use underscore.js + Angular filter to group it.
    $scope.updateModels = (job) ->
      if not job.device_filter.manufacturer?
        job.deviceOptions.models = []
        return
        # Reset job.deviceOptions.manufacturers
      job.deviceOptions.models = []
      for d in $scope.devices
        # Filtered by platform and manufacturer
        if d.platform isnt job.device_filter.platform
          continue
        if d.product.manufacturer isnt job.device_filter.manufacturer
          continue
        if job.deviceOptions.models.indexOf(d.product.model) is -1
          job.deviceOptions.models.push(d.product.model)
      return

    # TODO: use underscore.js + Angular filter to group it.
    $scope.updateDevices = (job) ->
      if not job.device_filter.model?
        job.deviceOptions.devices = []
        return
      job.deviceOptions.devices = []
      for d in $scope.devices
        # Filtered by platform and manufacturer
        if d.platform isnt job.device_filter.platform
          continue
        if d.product.manufacturer isnt job.device_filter.manufacturer
          continue
        if d.product.model isnt job.device_filter.model
          continue
        if job.deviceOptions.devices.indexOf(d.id) is -1
          job.deviceOptions.devices.push(d.id)
      return

    $scope.submitTask = () ->
      # split the device ID into mac and SN.
      for job in $scope.newTaskForm.jobs
        if job._the_device? and job._the_device.id?
          tokens = job._the_device.id.split("-")
          if tokens.length == 2
            job.device_filter = {}
            job.device_filter.mac = tokens[0]
            job.device_filter.serial = tokens[1]
          # delete _the_device
          delete job._the_device

      $http.post("api/tasks?access_token=" + gMY_TOKEN, $scope.newTaskForm).success (data) ->
        $location.path "/jobs"
        return;
      return

    return

  .controller 'AddTaskCtrl', ($scope, $http, $location) ->
    resort = () ->
      job.no = i for job, i in $scope.newTaskForm.jobs
      return
    createJob = () ->
      job = {}
      job.no = $scope.newTaskForm.jobs.length
      job.repo_url = $scope.newTaskForm.repo_url
      $scope.newTaskForm.jobs.push(job)
      job
    removeJob = (index) ->
      return if index >= $scope.newTaskForm.jobs.length
      $scope.newTaskForm.jobs.splice(index, 1)
      resort()
      return
    # TODO: Use underscore.js
    groupProductProperties = (key) ->
      result = []
      return result if $scope.devices.length is 0
      for d in $scope.devices
        #if d.product.hasOwnProperty(key) and d.product.
        if not d.product[key]?
          continue
        if result.indexOf(d.product[key]) == -1
          result.push(d.product[key])
      return result

    # Some initialization.
    $scope.newTaskForm = {}
    $scope.newTaskForm.jobs = []
    #createJob()

    # Retrieve the available devices first.
    $scope.devices = []
    $scope.manufacturers = $scope.models = []
    $http.get("api/devices?access_token=" + gMY_TOKEN).success (data) ->
      $scope.devices = data
      $scope.manufacturers = groupProductProperties("manufacturer")
      $scope.models = groupProductProperties("model")

    # Triggered when user clicks the button to add a job in a task.
    $scope.newJob = () ->
      createJob()

    # Triggered when user clicks the button to remove an existing job in a task.
    $scope.deleteJob = (index) ->
      removeJob(index)

    $scope.submitTask = () ->
      # split the device ID into mac and SN.
      for job in $scope.newTaskForm.jobs
        if job._the_device? and job._the_device.id?
          tokens = job._the_device.id.split("-")
          if tokens.length == 2
            job.device_filter = {}
            job.device_filter.mac = tokens[0]
            job.device_filter.serial = tokens[1]
          # delete _the_device
          delete job._the_device

      $http.post("api/tasks?access_token=" + gMY_TOKEN, $scope.newTaskForm).success (data) ->
        $location.path "/jobs"
        return;
      return
    return

