{type} = require 'cdeio/util/type'
objects = require 'cdeio/util/objects'
{cdeio} = require 'cdeio/config'
_ = require 'underscore'
{buildValidateRules} = require 'cdeio/validation/validator'
scaffoldRouter = require 'cdeio/scaffold/router'
_ = require 'underscore'
{Create, Update} = com.zyeeda.cdeio.validator.group
{TreeNode} = com.zyeeda.cdeio.commons.base.data
{ClassUtils} = org.springframework.util

exports.generateForms = (meta, labels = {}, forms, groups, formName, options) ->
    return null if not groups

    if not forms or not forms.defaults
        defaults = if groups['defaults'] then groups: ['defaults'] else groups: (groupName for groupName of groups)
    else
        defaults = forms.defaults
    if not forms or not forms[formName]
        form = if groups[formName] then groups: [formName] else defaults
    else
        form = forms[formName]

    generateForm form, meta, labels, groups, formName, options

generateForm = (form, meta, labels, fieldGroups, formName, options) ->
    groups = []
    for value in form.groups or []
        g = if type(value) is 'string' then name: value else objects.extend {}, value
        g.readOnly = true if formName is 'show'
        # g.readOnly = if _.isBoolean value.readOnly  then value.readOnly else if formName is 'show' then true  else false
        groups.push g

    result = {}
    result.labelOnTop = form.labelOnTop
    result.size = form.size
    result.custom = !!form.custom
    result.template = form.template
    result.groups = groups

    fg = result.fieldGroups = {}
    allFields = []
    for group in groups
        fields = []
        fields.push generateField(field, meta, labels, group.name, group) for field in fieldGroups[group.name] or []
        allFields = allFields.concat fields
        fg[group.name] = fields

    # if options.style is 'tree' or options.style is 'treeTable'
    #     fg['TREE_GROUP'] = [
    #         label: '父节点', name: 'parentName', value: 'parent.name', readOnly: true, type: 'text'
    #     ,
    #         name: 'parent', value: 'parent.id', type: 'hidden'
    #     ]
    #     result.groups.unshift 'TREE_GROUP'

    result.tabs = form.tabs

    validateGroup = if formName is 'add' then Create else Update

    if formName isnt 'filter'
        result.validation = buildValidateRules allFields, meta.entityClass, validateGroup
        if options.validation 
            result.validation.rules = _.extend (result.validation.rules || {}), options.validation.rules if options.validation.rules
            result.validation.messages = _.extend (result.validation.messages || {}), options.validation.messages if options.validation.messages
            result.validation.ignore = options.validation.ignore if options.validation.ignore
            result.validation.errorsAppend = options.validation.errorsAppend if options.validation.errorsAppend

    result.entityLabel = options.entityLabel if options.entityLabel

    fg = generateHiddenFields fg, formName, options
    result.groups.push name: 'hiddenFields'

    result

generateField = (config, meta, labels, groupName, group) ->
    field = config
    field = name: config if type(field) is 'string'

    defaults =
        label: labels[field.name]

    field = objects.extend defaults, field
    defineFieldType field, meta.getField(field.name), meta

    field

defineFieldType = (field, fieldMeta, entityMeta) ->
    if field.type is 'multi-picker' or field.type is 'multi-tree-picker'
        field.type = 'multi-tree-picker' if ClassUtils.isAssignable(TreeNode, fieldMeta.getType())
        if not field.source and (fieldMeta.isManyToManyTarget() or fieldMeta.isOneToMany())
            field.source = fieldMeta.getPath()
            return

    if field.type is 'inline-grid'
        field.source = field.source or fieldMeta.getPath()
        field.oneToMany = fieldMeta.oneToMany
        field.manyToManyOwner = fieldMeta.manyToManyOwner
        field.manyToManyTarget = fieldMeta.manyToManyTarget
        field.mappedBy = fieldMeta.mappedBy
        t = if field.oneToMany
            fieldMeta.manyType
        else if field.manyToManyTarget
            fieldMeta.manyToManyOwnerType
        else if field.manyToManyOwner
            fieldMeta.manyToManyTargetType

        options = scaffoldRouter.requireScaffoldConfig field.source
        grid = options['inline-grid'] or options['grid']
        field.grid = scaffoldRouter.wrapGrid grid, options
        field.allowPick = field.allowPick isnt false
        if field.allowPick
            if ClassUtils.isAssignable(TreeNode, t) then field.pickerType = 'tree-picker' else field.pickerType = 'grid-picker'

        return

    return if field.type
    return field.type = 'text' if not fieldMeta

    if fieldMeta.getType() is java.lang.Boolean
        field.type = 'dropdown'
        field.source = cdeio.booleanFieldPickerSource
        return
    if fieldMeta.getType() is java.util.Date
        field.type = 'datepicker'
        return
    if fieldMeta.isEntity()
        field.type = if ClassUtils.isAssignable(TreeNode, fieldMeta.getType()) then 'tree-picker' else 'grid-picker'
        field.source = field.source or fieldMeta.getPath()
        return

    field.type = 'text'

generateHiddenFields = (fieldGroups, formName, options) ->
    hiddenFields = []
    if formName == 'add'
        hiddenFields.push name: 'id', type: 'hidden'
        hiddenFields.push name: '__ID__', type: 'hidden', value: 'id'
        hiddenFields.push name: '__FORM_TYPE__', type: 'hidden', defaultValue: 'create'
        hiddenFields.push name: '__FORM_FLAG__', type: 'hidden', defaultValue: 'true'
    else if formName == 'edit'
        hiddenFields.push name: 'id', type: 'hidden'
        hiddenFields.push name: '__ID__', type: 'hidden', value: 'id'
        hiddenFields.push name: '__FORM_TYPE__', type: 'hidden', defaultValue: 'update'
        hiddenFields.push name: '__FORM_FLAG__', type: 'hidden', defaultValue: 'true'
    fieldGroups.hiddenFields = hiddenFields
    fieldGroups