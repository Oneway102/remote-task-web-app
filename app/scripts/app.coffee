'use strict'

angular.module('angApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize'
])
  .config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/login',
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
      .when '/workstations',
        templateUrl: 'views/workstations.html'
        controller: 'WksCtrl'
      .when '/devices',
        templateUrl: 'views/devices.html'
        controller: 'DevicesCtrl'
      .when '/tasks',
        templateUrl: 'views/tasks.html'
        controller: 'TasksCtrl'
      .when '/jobs',
        templateUrl: 'views/jobs.html'
        controller: 'JobsCtrl'
      .when '/addtask3',
        templateUrl: 'views/addtask3.html'
        controller: 'AddTaskCtrl3'
      .when '/addtask2',
        templateUrl: 'views/addtask2.html'
        controller: 'AddTaskCtrl2'
      .when '/addtask',
        templateUrl: 'views/addtask1.html'
        controller: 'AddTaskCtrl'
      .otherwise
        redirectTo: '/'
    $locationProvider.html5Mode true
  ]
