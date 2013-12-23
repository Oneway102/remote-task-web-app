'use strict'

angular.module('angApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize', 
  'http-auth-interceptor', 'services.authService', 'services.naviService'
])
  .config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/login',
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
      .when '/projects/:id',
        templateUrl: 'views/project.html'
        controller: 'ProjectCtrl'
      .when '/admin/tags',
        templateUrl: 'views/tags.html'
        controller: 'TagMgtCtrl'
      .when '/admin/users',
        templateUrl: 'views/users.html'
        controller: 'UserMgtCtrl'
      .when '/admin/devices',
        templateUrl: 'views/devicemgt.html'
        controller: 'DeviceMgtCtrl'        
      .when '/workstations',
        templateUrl: 'views/workstations.html'
        controller: 'WksCtrl'
      .when '/devices',
        templateUrl: 'views/devices.html'
        controller: 'DevicesCtrl'
      .when '/tasks',
        templateUrl: 'views/tasks.html'
        controller: 'TasksCtrl'
      .when '/projects/:id/tasks/:tid',
        templateUrl: 'views/jobs.html'
        controller: 'JobsCtrl'
      .when '/projects/:id/users',
        templateUrl: 'views/groupusers.html'
        controller: 'GroupUserCtrl'
      .when '/projects/:id/addtask3',
        templateUrl: 'views/addtask3.html'
        controller: 'AddTaskCtrl3'
      .when '/projects/:id/addtask',
        templateUrl: 'views/addtask2.html'
        controller: 'AddTaskCtrl2'
      .otherwise
        redirectTo: '/'
    $locationProvider.html5Mode true
  ]
