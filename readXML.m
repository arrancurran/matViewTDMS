% Load the XML file
function value = readXML(xmlFilePath, elementName)
    % Load the XML file
    xDoc = xmlread(xmlFilePath);

    % Get the root element
    root = xDoc.getDocumentElement();

    % Define a recursive function to find the desired element
    function value = findElementByName(node, name)
        value = [];
        if node.hasChildNodes()
            childNodes = node.getChildNodes();
            for k = 0:childNodes.getLength()-1
                child = childNodes.item(k);
                if strcmp(char(child.getNodeName()), 'Name') && strcmp(char(child.getTextContent()), name)
                    valueNode = child.getNextSibling();
                    while ~isempty(valueNode) && valueNode.getNodeType() ~= valueNode.ELEMENT_NODE
                        valueNode = valueNode.getNextSibling();
                    end
                    if ~isempty(valueNode)
                        value = char(valueNode.getTextContent());
                        return;
                    end
                end
                value = findElementByName(child, name);
                if ~isempty(value)
                    return;
                end
            end
        end
    end

    % Call the recursive function with the root element
    value = findElementByName(root, elementName);
end