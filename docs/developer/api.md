- [Format](#format)
- [Status Codes](#status-codes)
- [/api/burn](#apiburn)
- [/api/finding](#apifinding)
- [/api/filter](#apifilter)
- [/api/service](#apiservice)
- [/api/stats](#apistats)

## Format

All responses are in **JSON** with **UTF-8** character encoding.

## Status Codes

- **200** Successful GET, PUT, POST or DELETE.
- **400** Bad request parameters.
- **404** Record not found.
- **409** Validation failed.
- **500** Server error.

## /api/burn
The burn API allows you to submit new code burns and get information about existing burns.

- [GET /api/burn](#get-apiburn)
- [POST /api/burn](#post-apiburn)
- [GET /api/burn/{:id}](#get-apiburnid)

***

### GET /api/burn
Gets the list of burns matching specified criteria.  With no parameters specified, it will provide a paginated list of all burns at a rate of 100 per page as well as a total count of the results found.

#### Parameters (all optional):
* **service_id**:   An **integer** representing the service's ID
* **service_name**: A **string** representing the service name associated with the burn
* **revision**:     A **string** representing the commit SHA/tag
* **status**:       A **string** representing the current status of the burn
* **sort_by**:      A **string** for sortable field (**id**,**service_id**,**service_name**,**revision**,**code_lang**,**repo_url**,**status**)
* **order**:        A **string** for ascending/descending orader (**asc**,**desc**)
* **page**:         An **integer** for specifying the page of the paginated results
* **per_page**:     An **integer** to override the default of 100 results per page

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/burn?service_name=codeburner</code></pre>

#### Sample response:

```json
{
  "count":1,
  "results":
    [{
      "id":26,
      "revision":"1b92653ae6275421753726c4feff865a4db2503e",
      "status":"done","created_at":"2016-03-02T19:43:54.000Z",
      "updated_at":"2016-03-02T19:44:19.000Z",
      "repo_url":"https://github.com/groupon/codeburner",
      "code_lang":"Ruby, CoffeeScript, HTML, JavaScript, CSS",
      "num_files":78,
      "num_lines":5542,
      "service_id":5,
      "service_portal":null,
      "status_reason":"completed on 2016-03-02 13:44:19 -0600"}
    ]}
}
```
***

### POST /api/burn
Submit a new burn.  

Since a burn is considered a scan of a single revision of a given service, this will return a 409 validation error if you submit a duplicate service/revision combo.  

If you don't specify a revision it defaults to master-HEAD, and resolves that to a specific commit for you automatically.

#### Parameters (<strong>*</strong> <small>required</small>):
* <strong>*</strong>**service_name**: A **string** representing the service's identifying name
* <strong>*</strong>**repo_url**:     A **string** representing the full GitHub repository URL
* **revision**:                       A **string** representing either a commit SHA or release tag
* **notify**:                         A **string** representing the e-mail address to send a notification to on completion

#### Sample request:
<pre class="command-line" data-output="2-4"><code class="language-bash">curl -X POST -F service_name='codeburner' -F repo_url='https://github.com/groupon/codeburner'  http://localhost:8080/api/burn
</code></pre>

#### Sample response:

```json
{
  "burn_id":27,
  "service_id":5,
  "service_name":"codeburner",
  "revision":"6f94fb9a4bc6bc6493428cfca243c7c844c8cc5e",
  "status":"created"
}
```

### GET /api/burn/{:id}
Show information about an individual burn #**:id**

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/burn/26</code></pre>

#### Sample response:

```json
{
  "id":26,
  "revision":"1b92653ae6275421753726c4feff865a4db2503e",
  "status":"done",
  "created_at":"2016-03-02T19:43:54.000Z",
  "updated_at":"2016-03-02T19:44:19.000Z",
  "repo_url":"https://github.com/groupon/codeburner",
  "code_lang":"Ruby, CoffeeScript, HTML, JavaScript, CSS",
  "num_files":78,
  "num_lines":5542,
  "service_id":5,
  "service_portal":null,
  "status_reason":"completed on 2016-03-02 13:44:19 -0600"
}
```

***

## /api/filter
The filter API allows you to list, create, and delete filters.

- [GET /api/filter](#get-apifilter)
- [POST /api/filter](#post-apifilter)
- [GET /api/filter/{:id}](#get-apifilterid)
- [DELETE /api/filter/{:id}](#delete-apifilterid)

***

### GET /api/filter
Lists all existing filters.  Non-paginated list by default.

#### Parameters (all optional)
* **sort_by**:      A **string** for sortable field (**id**,**service_id**)
* **order**:        A **string** for ascending/descending orader (**asc**,**desc**)
* **page**:         An **integer** for specifying the page of the paginated results
* **per_page**:     An **integer** to override the default of 100 results per page if requesting pagination

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/filter</code></pre>

#### Sample response:

```json
{
  "count":4,
  "results":
  [{
    "id":2,
    "service_id":5,
    "severity":null,
    "fingerprint":null,
    "scanner":"DawnScanner",
    "description":null,
    "detail":null,
    "file":null,
    "line":null,
    "code":null,
    "created_at":"2016-03-02T22:07:31.000Z",
    "updated_at":"2016-03-02T22:07:31.000Z",
    "finding_count":2
  }]
}
```

***

### POST /api/filter
Create a new filter.  All findings (existing and future) matching the provided combination of parameters will be marked with status **3** (filtered) .  

This will return a 409 validation error on attempting to create a duplicate filter.

#### Parameters (all optional):
* **service_id**:   An **integer** representing a specific service ID
* **severity**:     An **integer** representing severity as reported by pipeline
* **fingerprint**:  A **string** representing the SHA256 fingerprint calculated by pipeline
* **scanner**:      A **string** representing an individual scanning tool
* **description**:  A **string** representing a finding description
* **detail**:       A **string** representing a finding extended detail
* **file**:         A **string** representing a specific file name
* **line**:         A **string** representing the line number (this is a string vs. integer to allow for a TODO item)
* **code**:         A **string** representing a code snippet returned by a scanning tool

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -X POST -F service_id='5' -F scanner='Brakeman' http://localhost:8080/api/filter</code></pre>

#### Sample response:

```json
{
  "id":4,
  "service_id":5,
  "severity":null,
  "fingerprint":null,
  "scanner":"Brakeman",
  "description":null,
  "detail":null,
  "file":null,
  "line":null,
  "code":null,
  "created_at":"2016-03-03T22:10:57.665Z",
  "updated_at":"2016-03-03T22:10:57.665Z"
}
```

***

### GET /api/filter/{:id}
Show a specific filter #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/filter/4</code></pre>

#### Sample response:

```json
{
  "id":4,
  "service_id":5,
  "severity":null,
  "fingerprint":null,
  "scanner":"Brakeman",
  "description":null,
  "detail":null,
  "file":null,
  "line":null,
  "code":null,
  "created_at":"2016-03-03T22:10:57.665Z",
  "updated_at":"2016-03-03T22:10:57.665Z"
}
```

***

### DELETE /api/filter/{:id}
Delete a specific filter #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' -X DELETE http://localhost:8080/api/filter/4</code></pre>

#### Sample response:

```json
{"result":"success"}
```

***

## /api/finding
The finding API allows you to view findings, publish them to your issue tracker of choice, and modify status.

- [GET /api/finding](#get-apifinding)
- [GET /api/finding/{:id}](#get-apifindingid)
- [PUT /api/finding/{:id}](#put-apifindingid)
- [PUT /api/finding/{:id}/publish](#put-apifindingidpublish)

***

### GET /api/finding
Gets the list of findings matching specified criteria.  With no parameters specified, it will provide a paginated list of all findings at a rate of 100 per page as well as a total count of the results found.

#### Parameters (all optional):
* **service_id**:   An **integer** representing the service ID
* **burn_id**:      An **integer** representing the burn ID
* **service_name**: A **string** representing the service name associated with the burn
* **severity**:     An **integer** representing the severity as reported by pipeline
* **description**:  A **string** representing the finding description
* **fingerprint**:  A **string** representing the SHA256 fingerprint calculated by pipeline
* **status**:       An **integer** representing the status (**0**=created,**1**=hidden,**2**=published,**3**=filtered)
* **sort_by**:      A **string** for sortable field (**id**,**service_id**,**service_name**,**severity**,**fingerprint**,**status**,**description**)
* **order**:        A **string** for ascending/descending orader (**asc**,**desc**)
* **page**:         An **integer** for specifying the page of the paginated results
* **per_page**:     An **integer** to override the default of 100 results per page

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/findings?service_name=codeburner?per_page=1</code></pre>

#### Sample response:

```json
{
  "count":14,
  "results":
  [{
    "id":158,
    "description":"Unscoped Find",
    "severity":1,
    "fingerprint":"3281689afd550427eed28c24fc3e7e8926838e78249f1b445326dda3c0ac1d50",
    "detail":"Unscoped call to Finding#find\nhttp://brakemanscanner.org/docs/warning_types/unscoped_find/",
    "created_at":"2016-03-02T19:44:19.000Z",
    "updated_at":"2016-03-02T19:44:19.000Z",
    "status":0,
    "burn_id":26,
    "service_id":5,
    "scanner":"Brakeman",
    "file":"app/controllers/api/finding_controller.rb",
    "line":225,
    "code":"Finding.find(params[:id])",
    "filter_id":null
    }]
}
```

***

### GET /api/finding/{:id}
Show information about an individual finding #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/finding/158</code></pre>

#### Sample response:

```json
{
  "id":158,
  "description":"Unscoped Find",
  "severity":1,
  "fingerprint":"3281689afd550427eed28c24fc3e7e8926838e78249f1b445326dda3c0ac1d50",
  "detail":"Unscoped call to Finding#find\nhttp://brakemanscanner.org/docs/warning_types/unscoped_find/",
  "created_at":"2016-03-02T19:44:19.000Z",
  "updated_at":"2016-03-02T19:44:19.000Z",
  "status":0,
  "burn_id":26,
  "service_id":5,
  "scanner":"Brakeman",
  "file":"app/controllers/api/finding_controller.rb",
  "line":225,
  "code":"Finding.find(params[:id])",
  "filter_id":null
}
```

***

### PUT /api/finding/{:id}
Update attributes (currently only **status**) for a specific finding #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' -X PUT -d '{"status":1}' http://localhost:8080/api/finding/158</code></pre>

#### Sample response:

```json
{
  "id":158,
  "description":"Unscoped Find",
  "severity":1,
  "fingerprint":"3281689afd550427eed28c24fc3e7e8926838e78249f1b445326dda3c0ac1d50",
  "detail":"Unscoped call to Finding#find\nhttp://brakemanscanner.org/docs/warning_types/unscoped_find/",
  "created_at":"2016-03-02T19:44:19.000Z",
  "updated_at":"2016-03-03T21:14:35.827Z",
  "status":1,
  "burn_id":26,
  "service_id":5,
  "scanner":"Brakeman",
  "file":"app/controllers/api/finding_controller.rb",
  "line":225,
  "code":"Finding.find(params[:id])",
  "filter_id":null
}
```

***

### PUT /api/finding/{:id}/publish
Publish a specific finding #**:id** to your issue tracker of choice.

#### Parameters (<strong>*</strong> <small>required</small>):
* <string>*</strong>**method**: A **string** representing the desired publishing method (**github**,**jira**)
* **project**:                  A **string** representing the JIRA project if you're using that publishing method

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' -X PUT -d '{"method":"github"}' http://localhost:8080/api/finding/158/publish</code></pre>

#### Sample response:

```json
{
  "ticket":"groupon/codeburner - Issue #5",
  "link":"https://github.com/groupon/codeburner/issues/5"
}
```

***


## /api/service
The service API can be used to list services, find information about a specific service, and generate history/statistics.

- [GET /api/service](#get-apiservice)
- [GET /api/service/{:id}](#get-apiserviceid)
- [GET /api/service/{:id}/stats](#get-apiserviceidstats)
- [GET /api/service/{:id}/stats/burns](#get-apiserviceidstatsburns)
- [GET /api/service/{:id}/stats/history](#get-apiserviceidstatshistory)
- [GET /api/service/{:id}/stats/history/range](#get-apiserviceidstatshistoryrange)
- [GET /api/service/{:id}/stats/history/resolution](#get-apiserviceidstatshistoryresolution)

### GET /api/service
List all services.  Results are non-paginated.  This query result is cached in redis and should generally return very quickly even with a large number of services.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service</code></pre>

#### Sample response:

```json
{
  "count":1,
  "results":
  [{
    "id":5,
    "short_name":"codeburner",
    "pretty_name":"codeburner",
    "created_at":"2016-03-01T17:54:07.000Z",
    "updated_at":"2016-03-01T17:54:07.000Z",
    "service_portal":null
  }]
}
```

***

### GET /api/service/{:id}
Show information about a specific service #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5</code></pre>

#### Sample response:

```json
{
  "id":5,
  "short_name":"codeburner",
  "pretty_name":"codeburner",
  "created_at":"2016-03-01T17:54:07.000Z",
  "updated_at":"2016-03-01T17:54:07.000Z",
  "service_portal":null
}
```

***

### GET /api/service/{:id}/stats
Get statistics about a specific service #**id**.  If you want statistics about all services, see [/api/stats](#apistats).

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5/stats</code></pre>


#### Sample response:

```json
{
  "burns":2,
  "open_findings":10,
  "total_findings":14,
  "filtered_findings":3,
  "hidden_findings":0,
  "published_findings":1
}
```

***

### GET /api/service/{:id}/stats/burns
Get a list of [date, count] pairs where count is the number of burns performed against a specific service on date.

#### Parameters (all optional):
* **start_date**: A **string** representing the start_date for the list, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the list, parsable by ruby Time.parse().

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5/stats/burns</code></pre>

#### Sample response:

```json
[
  ["2016-03-02",1],
  ["2016-03-03",1]
]
```

***

### GET /api/service/{:id}/stats/history
Generate point-in-time statistics (comparable to the /api/service/{:id}/stats output) for a service from **start_date** to **end_date** with a timestep of **resolution**.

The default **start_date** is the date of the first burn on the service, and the default **end_date** is ruby Time.now().  

The default **resolution** is calculated automatically based on the length of time between the two dates to generate smooth trend lines when graphed.  It ranges from 1 hour to 1 week.

#### Parameters (all optional):
* **start_date**: A **string** representing the start_date for the history, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the history, parsable by ruby Time.parse().
* **resolution**: An **integer** representing the timestep used to sample stats, in seconds.

!!! Warning
    Be careful with the resolution setting.  If you set this too low (say, every 5 minutes on multiple months of history) you can generate a **very** large number of database queries and cause considerable slowdown.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5/stats/history/resolution=259200</code></pre>

#### Sample response:

```json
{
  "services":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",1]],
  "burns":[
    ["2016-03-01T17:54:08.000Z",1],
    ["2016-03-03T16:52:21.575-06:00",2]],
  "total_findings":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",14]],
  "open_findings":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",10]],
  "hidden_findings":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",0]],
  "published_findings":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",1]],
  "filtered_findings":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",3]],
  "files":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",78]],
  "lines":[
    ["2016-03-01T17:54:08.000Z",0],
    ["2016-03-03T16:52:21.575-06:00",5542]]
}
```

***

### GET /api/service/{:id}/stats/history/range
Show the default **start_date**, **end_date** and **resolution** for history of a specific service #**:id**.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5/stats/history/range</code></pre>

#### Sample response:

```json
{
  "start_date":"2016-03-01T17:54:08.000Z",
  "end_date":"2016-03-03T16:57:54.720-06:00",
  "resolution":14400
}
```

***

### GET /api/service/{:id}/stats/history/resolution
Show the default **resolution** for a given **start_date** and **end_date** for a specific service #**:id**.

#### Parameters (all required):
* **start_date**: A **string** representing the start_date for the resolution, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the resolution, parsable by ruby Time.parse().

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/service/5/stats/history/resolution?start_date=2016-03-01T23:06:49.107Z&end_date=2016-03-03T17:07:05.428-06:00</code></pre>

#### Sample response:

```json
14400
```

***

## /api/stats
The stats API provides overall statistics and history for everything done by Codeburner.  If you want to pull statistics for an individual service, see [/api/service/{:id}/stats](#get-apiserviceidstats).

All times are passed as **JSON-encoded UTC**, and the data is generally structured to be easily mapped to a <a href="https://developers.google.com/chart/interactive/docs/reference#DataTable" target="_blank">Google Visualization DataTable</a> object.  

If you want to incorporate Codeburner data in your existing dashboards or otherwise roll your own graphs, it should map fairly cleanly to most popular graphing implementations.  A handful of libraries that have worked well with the data internally:  <a href="https://github.com/ankane/chartkick.js" target="_blank">chartkick</a>, <a href="https://gionkunz.github.io/chartist-js/" target="_blank">chartist</a>, <a href="https://github.com/topfunky/gruff" target="_blank">gruff</a>.

- [GET /api/stats](#get-apistats)
- [GET /api/stats/burns](#get-apistatsburns)
- [GET /api/stats/history](#get-apistatshistory)
- [GET /api/stats/history/range](#get-apistatshistoryrange)
- [GET /api/stats/history/resolution](#get-apistatshistoryresolution)

### GET /api/stats
Get statistics for number of findings in each category (**open**, **hidden**, **published**, **filtered**), total lines/files burned, number of services and number of burns.  This response is cached in redis and should respond very quickly.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/stats</code></pre>

#### Sample response:

```json
{
  "services":1,
  "burns":2,
  "total_findings":14,
  "open_findings":10,
  "hidden_findings":0,
  "published_findings":1,
  "filtered_findings":3,
  "files":78,
  "lines":5542
}
```

***

### GET /api/stats/burns
Get a list of [date, count] pairs where count is the number of burns performed on date.

#### Parameters (all optional):
* **start_date**: A **string** representing the start_date for the list, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the list, parsable by ruby Time.parse().

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/stats/burns</code></pre>


#### Sample response:

```json
[
  ["2016-03-02",1],
  ["2016-03-03",1],
  ["2016-03-04",0]
]
```

***

### GET /api/stats/history
Generate point-in-time statistics (comparable to the /api/stats output) for a service from **start_date** to **end_date** with a timestep of **resolution**.

The default **start_date** is the date of the first burn, and the default **end_date** is ruby Time.now().  

The default **resolution** is calculated automatically based on the length of time between the two dates to generate smooth trend lines when graphed.  It ranges from 1 hour to 1 week.

#### Parameters (all optional):
* **start_date**: A **string** representing the start_date for the history, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the history, parsable by ruby Time.parse().
* **resolution**: An **integer** representing the timestep used to sample stats, in seconds.

!!! Warning
    Be careful with the resolution setting.  If you set this too low (say, every 5 minutes on multiple months of history) you can generate a **very** large number of database queries and cause considerable slowdown.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/stats/history?resolution=400000</code></pre>

#### Sample response:

```json
{
  "services":[
    ["2016-02-25T21:18:22.000Z",1],
    ["2016-03-01T12:25:02.000Z",1],
    ["2016-03-04T09:36:45.985-06:00",1]],
  "burns":[
    ["2016-02-25T21:18:22.000Z",1],
    ["2016-03-01T12:25:02.000Z",1],
    ["2016-03-04T09:36:45.985-06:00",2]],
  "total_findings":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",4],
    ["2016-03-04T09:36:45.985-06:00",14]],
  "open_findings":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",4],
    ["2016-03-04T09:36:45.985-06:00",10]],
  "hidden_findings":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",0],
    ["2016-03-04T09:36:45.985-06:00",0]],
  "published_findings":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",0],
    ["2016-03-04T09:36:45.985-06:00",1]],
  "filtered_findings":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",0],
    ["2016-03-04T09:36:45.985-06:00",3]],
  "files":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",18],
    ["2016-03-04T09:36:45.985-06:00",78]],
  "lines":[
    ["2016-02-25T21:18:22.000Z",0],
    ["2016-03-01T12:25:02.000Z",1817],
    ["2016-03-04T09:36:45.985-06:00",5542]]
}
```

***

### GET /api/stats/history/range
Show the default **start_date**, **end_date** and **resolution** for full Codeburner history.

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/stats/history/range</code></pre>

#### Sample response:

```json
{
  "start_date":"2016-02-25T21:18:22.000Z",
  "end_date":"2016-03-04T09:41:10.342-06:00",
  "resolution":43200
}
```

***

### GET /api/stats/history/resolution
Show the default **resolution** for a given **start_date** and **end_date**.

#### Parameters (all required):
* **start_date**: A **string** representing the start_date for the resolution, parsable by ruby Time.parse().
* **end_date**:   A **string** representing the end_date for the resolution, parsable by ruby Time.parse().

#### Sample request:
<pre class="command-line"><code class="language-bash">curl -H 'Content-type: application/json' http://localhost:8080/api/stats/history/resolution?start_date=2016-03-01T23:06:49.107Z&end_date=2016-03-03T17:07:05.428-06:00</code></pre>

#### Sample response:

```json
14400
```

***
