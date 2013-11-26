

exports.index = (req, res) ->
  res.render("index.html")

exports.partials = (req, res) ->
  name = req.params.name
  res.render('partials/' + name)
