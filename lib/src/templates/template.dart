part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.


/**
* ## Helper class for working with Buckshot templates. ##
*
* ## Supported Formats ##
* * XML
* * JSON
* * YAML (coming soon)
*
* ## Usage ##
* Both YAML and JSON templates require a certain heirachy in order to
* deserialize properly:
*
*     [element,
*       [{property1:value, property2:value},
*       [childElement1,
*         [{property:value}],
*        childElement2,
*         [{property:value}]
*       ]
*     ]
*
* ### XML Example ###
*     <border padding='5' background='Orange'>
*        <stack halign='center' valign='center'>
*          <textblock text='hello' />
*          <textblock text='world' />
*        </stack>
*     </border>
*
* ### JSON Example ###
*     ["border",
*        [{"background" : "Orange", "padding" : "10"},
*          ["stack",
*            [{"valign" : "center", "halign" : "center"},
*              ["textblock",
*                [{"text" : "hello"}]
*              ,"textblock",
*                [{"text" : "world"}]
*              ]
*            ]
*          ]
*        ]
*      ]
*
* ### YAML Example ###
*     - border
*     - - {background: Orange, padding: 10}
*       - - stack
*         - - {halign: center, valign: center}
*           - - textblock
*             - - text: hello
*             - textblock
*             - - text: world
*
*/
class Template {

  //TODO make providers discoverable via reflection instead of pre-registered.
  final List<IPresentationFormatProvider> providers =
      [new XmlTemplateProvider()];

  static const int _UNKNOWN = -1;
  static const int _HTML_ELEMENT = 0;
  static const int _HTTP_RESOURCE = 1;
  static const int _SERIALIZED = 2;

  /**
   * Returns the first parent that matches the given [type].  Returns
   * null if parent not found in visual tree.
   *
   * Case sensitive.
   */
  static FrameworkElement findParentByType(FrameworkElement element,
                                           String type){
    if (element.parent == null) return null;

    if (reflectionEnabled){
      if (buckshot.reflectMe(element.parent).type.simpleName != type){
        return findParentByType(element.parent, type);
      }
    }else{
      if (element.parent.runtimeType.toString() != type){
        return findParentByType(element.parent, type);
      }
    }

    return element.parent;
  }


  /** Performs a search of the element tree starting from the given
   * [FrameworkElement] and returns the first named Element matching
   * the given name.
   *
   * ## For most cases, consider using: ##
   *     namedElements[elementName];
   */
  static FrameworkElement findByName(String name,
                                     FrameworkElement startingWith){

    if (startingWith.name.value != null && startingWith.name.value == name){
      return startingWith;
    }

    if (!startingWith.isContainer){
      return null;
    }

    var cc = startingWith.stateBag[FrameworkObject.CONTAINER_CONTEXT];
    if (cc is List){
      for (final el in cc){
        var result = findByName(name, el);
        if (result != null) return result;
      }
    }else if (cc is FrameworkProperty){
      final obj = cc.value;
      if (obj == null || !(obj is FrameworkElement)) return null;
      return findByName(name, obj);
    }else{
      return null;
    }
  }

  /**
  * Used to determine the type of the string.
  *
  * Checks to see if its referencing a [_HTML_ELEMENT], a [_HTTP_RESOURCE]
  * or one of the serialized types [_SERIALIZED].
  */
  static int _determineType(String from) {
    if (from.startsWith('#')) {
      return _HTML_ELEMENT;
    }else{
      final t = new Template();

      for(final p in t.providers){
        if(p.isFormat(from)){
          return _SERIALIZED;
        }
      }
    }

    // Assume its pointing to a HTTP resource
    return _HTTP_RESOURCE;
  }

  /**
  * # Usage #
  *     //Retrieves the template from the current web page
  *     //and returns a String containing the template
  *     //synchronously.
  *
  *     getTemplate('#templateID').then(...);
  *
  *     //Retrieves the template from the URI (same domain)
  *     //and returns a Future<String> containing the template.
  *
  *     getTemplate('/relative/path/to/templateName.xml').then(...);
  *
  * Use the [deserialize] method to convert a template to a [FrameworkObject].
  */
  static Future<String> getTemplate(String from, {type: _UNKNOWN}){
    var c = new Completer();

    if (type == _UNKNOWN) {
      type = _determineType(from);
    }

    if (type == _HTML_ELEMENT) {
      var result = document.query(from);
      if (result == null) {
        throw new BuckshotException('Unabled to find template'
            ' "${from}" in HTML file.');
      }

      c.complete(result.text.trim());
    }else if (type == _HTTP_RESOURCE){
      //TODO cache...

      var r = new HttpRequest();

      void onError(e) {
        c.complete(null);
      }

      r.on.abort.add(onError);
      r.on.error.add(onError);
      r.on.loadEnd.add((e) {
        c.complete(r.responseText.trim());
      });

      try{
        r.open('GET', from, true);
        r.setRequestHeader('Accept', 'text/xml');
        r.send();
      }on Exception catch(e){
        c.complete(null);
      }
    }else{
      c.complete(from);
    }

    return c.future;
  }

  /**
  * Takes a buckshot Template and attempts deserialize it into an object
  * structure.
  *
  * This method will attempt to auto-detect the template format and apply
  * the appropriate implementation.
  *
  * ### Supported Formats ###
  * * XML
  * * JSON
  * * YAML
  */
  static Future<FrameworkElement> deserialize(String buckshotTemplate){
    final tt = buckshotTemplate.trim();
    var rawTemplate;

    return _initFramework()
              .chain((_) => Template.getTemplate(tt))
              .chain((template){
                rawTemplate = template;
                return Template.toFrameworkObject(Template.toXmlTree(template));
              })
              .chain((result){
                if (result == null){
                  return new Future.immediate(result);
                }
                result.stateBag['__buckshot_template__'] = rawTemplate;
                return new Future.immediate(result);
              });

  }

  /**
   * Low-level function which returns a normalized Xml Tree from a given Xml,
   * Json, or Yaml [template].
   *
   * This function does not normally need to be called directly.  Use
   * Template.deserialize() instead.
   */
  static XmlElement toXmlTree(String template){
    final t = new Template();

    for(final p in t.providers){
      if(p.isFormat(template)){
        return p.toXmlTree(template);
      }
    }

    throw new BuckshotException('Unable to determine a template provider for'
        ' the given template.');
  }


  /**
   * Returns a [FrameworkObject] in a [Future] representing the deserialized
   * instance of a given [xmlElement] tree.
   *
   * The [xmlElement] tree most conform to the Buckshot template schema.
   */
  static Future<FrameworkObject> toFrameworkObject(XmlElement xmlElement){

    final oc = new Completer();

    String lowerTagName = xmlElement.name.toLowerCase();

    void completeElementParse(element){
      if (element is FrameworkResource){
        element.rawData = xmlElement.toString();
        _processResource(element);
        // complete nodes as null; they aren't added to the DOM
        oc.complete(null);
      }else{
        oc.complete(element);
      }
    }

    final objectOrMirror = getObjectByName(lowerTagName);

    if (objectOrMirror == null){
      throw new TemplateException('Element "${xmlElement.name}"'
      ' not found.');
    }

    void processElement(newElement){
      final fList = [];

      if (xmlElement.children.length > 0 &&
          xmlElement.children.every((n) => n is! XmlText)){
        //process nodes

        fList.addAll(xmlElement.children.map((e) =>
          (newElement.hasProperty(e.name.toLowerCase()))
              ? _processProperty(newElement, e)
              : _processTag(newElement, e)
          )
        );
      }else{
        //no nodes, check for text element
        _processTextNode(newElement, xmlElement);
      }

      //add the assign attributes future to the list.
      fList.add(_assignAttributeProperties(newElement, xmlElement));

      // Wait for all the futures to complete before finishing
      Futures
      .wait(fList)
      .then((_){
        completeElementParse(newElement);
      });
    }

    if (!reflectionEnabled){
      assert(objectOrMirror is BuckshotObject);
      processElement(objectOrMirror);
    }else{
      objectOrMirror
      .newInstance('',[])
      .then((newElementMirror){
        processElement(newElementMirror.reflectee);
      });
    }

    return oc.future;
  }

  static Future _processEvent(ofElement, String e, v){
    final c = new Completer();

    ofElement.getEventByName(e)
    .then((event){
      if (event is! FrameworkEvent || ofElement is! FrameworkObject){
        c.complete(false);
        return;
      }
      // registered the handler name and the event for later binding
      // when the data context is set.
      ofElement._eventBindings[v] = event;

      c.complete(true);
    });

    return c.future;
  }


  static Future _processProperty(ofElement, XmlElement ofXMLNode){
    final c = new Completer();
    final String lowered = ofXMLNode.name.toLowerCase();

    //property node
    ofElement.getPropertyByName(lowered)
    .then((p){
      if (p == null) { throw new TemplateException("Property node"
          " name '${lowered}' is not a valid"
          " property of ${ofElement.type}.");
      }

      if (lowered == "itemstemplate"){
        //accomodation for controls that use itemstemplates...
        if (ofXMLNode.children.length != 1){
          throw const TemplateException('ItemsTemplate'
          ' can only have a single child.');
        }
        // defer parsing of the template xml, the template
        // iterator should handle later.
        p.value = ofXMLNode.children[0].toString();
        c.complete(true);
      }else{
        final propertyValue = p.value;

        if (propertyValue != null && propertyValue is List){
          Futures
          // cast to List required because XmlCollection subclasses
          // Collection<T>
          .wait(new List.from(ofXMLNode.children.map((se) =>
              toFrameworkObject(se))))
          .then((results){
            results.forEach((r){
              propertyValue.add(r);
            });
            c.complete(true);
          });

        }else if (ofXMLNode.text.trim().startsWith("{")){

          //binding or resource
          _resolveBinding(p, ofXMLNode.text.trim());
          c.complete(true);
        }else{
          //property node

          if (ofXMLNode.children.isEmpty){
            //assume text assignment
            p.value = ofXMLNode.text.trim();
            c.complete(true);
          }else{
            if (ofXMLNode.children.every((n) => n is XmlText)){
              // text assignment to property
              p.value = ofXMLNode.text.trim();
              c.complete(true);
            }else if (ofXMLNode.children.length == 1 &&
                ofXMLNode.children[0] is! XmlText){

              // node assignment to property

              toFrameworkObject(ofXMLNode.children[0])
                .then((ne){
                  p.value = ne;
                  c.complete(true);
              });
            }
          }
        }
      }

    });

    return c.future;
  }

  static Future _processTag(ofElement, ofXMLNode){
    final c = new Completer();
    final String elementLowerTagName = ofXMLNode.name.toLowerCase();

    if (ofXMLNode.name.contains(".")){
      if (reflectionEnabled){
        AttachedFrameworkProperty
          .invokeSetPropertyFunction(ofXMLNode.name,
              ofElement,
              ofXMLNode.text.trim());
      }else{
        if (_objectRegistry.containsKey(ofXMLNode.name.toLowerCase())){
          _objectRegistry
          [ofXMLNode.name.toLowerCase()](ofElement, ofXMLNode.text.trim());
        }
      }
      c.complete(true);
    }else{
      //element or resource

      if (!ofElement.isContainer) {
        throw const TemplateException("Attempted to add"
        " element to another element which is not a container.");
      }

      final cc = ofElement.stateBag[FrameworkObject.CONTAINER_CONTEXT];

      toFrameworkObject(ofXMLNode).then((childElement){

        if (childElement == null){
          c.complete(true); // is a resource
          return;
        }

        // CONTAINER_CONTEXT is a FrameworkProperty for single element, List
        // for multiple
        if (cc is List){
          //list content
          cc.add(childElement);
        }else if (cc is FrameworkProperty){
          // single child (previous child will be overwritten
          // if multiple are provided)
          //TODO throw on multiple child element nodes
          cc.value = childElement;
        }else{
          throw const BuckshotException('container context type is invalid.');
        }
        c.complete(true);
      });
    }

    return c.future;
  }

  static void _processTextNode(ofElement, ofXMLNode){
    if (ofXMLNode.text.trim() != ""){
      if (!ofElement.isContainer) {
        throw const TemplateException("Text node found in element"
        " which does not have a container context defined.");
      }

      var cc = ofElement.stateBag[FrameworkObject.CONTAINER_CONTEXT];

      if (cc is List) { throw const TemplateException("Expected"
      " container context to be property.  Found list.");
      }

      cc.value = ofXMLNode.text.trim();
    }
  }

  static void _resolveBinding(FrameworkProperty p, String binding){
    if (!binding.startsWith("{") || !binding.endsWith("}")) {
      throw const TemplateException('Binding must begin with'
        ' "{" and end with "}"');
    }

    FrameworkProperty placeholder = new FrameworkProperty(null, "placeholder");

    String stripped = binding.substring(1, binding.length - 1);

    BindingMode mode = BindingMode.OneWay;
    IValueConverter vc = null;

    //TODO support converters...
    var params = stripped.split(',');

    var words = params[0].trim().split(' ');

    if (params.length > 1 && words[0] != "template"){
      params
        .getRange(1, params.length - 1)
        .forEach((String param){
          String lParam = param.trim().toLowerCase();
          if (lParam.startsWith('mode=') || lParam.startsWith('mode =')){
            var modeSplit = lParam.split('=');
            if (modeSplit.length == 2){
              switch(modeSplit[1]){
                case "twoway":
                    mode = BindingMode.TwoWay;
                  break;
                case "onetime":
                    mode = BindingMode.OneTime;
                  break;
              }
            } //TODO: else throw?

          }
          else if (lParam.startsWith('converter=')
              || lParam.startsWith('converter ='))
          {
            var converterSplit = lParam.split('=');

            if (converterSplit.length == 2
                && converterSplit[1].startsWith('{resource ')
                && converterSplit[1].endsWith('}')){
              _resolveBinding(placeholder, converterSplit[1]);
              var testValueConverter = placeholder.value;
              if (testValueConverter is IValueConverter) {
                vc = testValueConverter;
              }
            } //TODO: else throw?
          }
        });
    }

    switch(words[0]){
      case "resource":
        if (words.length != 2) {
          throw const TemplateException('Binding'
            ' syntax incorrect.');
        }

        p.value = getResource(words[1]);
        break;
      case "template":
        if (words.length != 2){
          throw const TemplateException('{template} binding malformed.');
        }
        //log('setting template binding: ${words[1]}', element: p.sourceObject);
        (p.sourceObject as FrameworkElement)._templateBindings[p] = words[1];
        break;
      case "data":
        if (p.sourceObject is! FrameworkElement){
          throw const TemplateException('{data...} binding only'
            ' supported on types that derive from FrameworkElement.');
        }

        final so = p.sourceObject as FrameworkObject;
        switch(words.length){
          case 1:
            //dataContext directly
            so.lateBindings[p] = new BindingData("", null, mode);
            break;
          case 2:
            //dataContext object via property resolution
            //log('setting up late binding for property ${p.propertyName} with string ${words[1]}', element: so);
            so.lateBindings[p] = new BindingData(words[1], null, mode);
            break;
          default:
            throw const TemplateException('Binding'
              ' syntax incorrect.');
        }
        break;
      case "element":
        if (words.length != 2) {
          throw const TemplateException('Binding'
            ' syntax incorrect.');
        }

        if (words[1].contains(".")){
          var ne = words[1].substring(0, words[1].indexOf('.'));
          var prop = words[1].substring(words[1].indexOf('.') + 1);

          if (!namedElements.containsKey(ne)) {
            throw new TemplateException("Named element '${ne}'"
            " not found.");
          }

          Binding b;

            namedElements[ne]
            .resolveProperty(prop)
            .then((property){
              if (property != null){
                new Binding(property, p, bindingMode:mode);
              }else{
                namedElements[ne]
                .resolveFirstProperty(prop)
                .then((firstProperty){
                  firstProperty.propertyChanging + (_, __) {

                    //unregister previous binding if one already exists.
                    if (b != null) b.unregister();

                    namedElements[ne]
                    .resolveProperty(prop)
                    .then((lateProperty){
                      b = new Binding(lateProperty, p, bindingMode:mode);
                    });
                  };
                });
              }
            });
        }else{
          throw const TemplateException("Element binding requires"
            " a minimum named element/property"
            " pairing (usage '{element name.property}')");
        }
        break;
      default:
        throw const TemplateException('Binding syntax incorrect.');
    }
  }

  static void _processResource(FrameworkResource resource){
    //ignore the collection object, the resources will come here anyway
    //TODO: maybe support merged resource collections in the future...
    if (resource is ResourceCollection) return;

    if (resource.key.value.isEmpty) {
      throw const TemplateException("Resource is missing"
        " a key identifier.");
    }

    //add/replace resource at given key
    registerResource(resource);
  }

  static Future _assignAttributeProperties(BuckshotObject element,
                                  XmlElement xmlElement){
    final c = new Completer();

    if (xmlElement.attributes.length == 0){
      c.complete(false);
      return c.future;
    }

    final fList = [];

    xmlElement
      .attributes
      .forEach((String k, String v){
        if (k.contains(".")){
          if (k.startsWith('on.')){
            // event
            final tk = k.substring(3, k.length);
            if (element.hasEvent(tk.toLowerCase())){
              fList.add(_processEvent(element, tk, v));
            }
          }else{
            // attached property
            if (reflectionEnabled){
              AttachedFrameworkProperty
                .invokeSetPropertyFunction(k, element, v);
            }else{
              if (_objectRegistry.containsKey(k.toLowerCase())){
                _objectRegistry[k.toLowerCase()](element, v);
              }
            }
          }
        }else{
          // property
          final f = element.resolveProperty(k.toLowerCase());
          fList.add(f);
          f.then((FrameworkProperty p){
            if (p == null) return;

            if (v.trim().startsWith("{")){
              //binding or resource
              _resolveBinding(p, v.trim());
            }else{
              //value or enum (enums converted at property level
              //via FrameworkProperty.stringToValueConverter [if assigned])
              p.value = v;
            }
          });
        }
    });

    //make sure all the values are set before completing the future.
    Futures
    .wait(fList)
    .then((_) => c.complete(true));

    return c.future;
  }
}
