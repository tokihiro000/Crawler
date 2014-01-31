# -*- coding: utf-8 -*-
=begin

Red_Black_Treeを構成するクラスです。
今のところ挿入、検索、挿入時回転のみが実装されています。
削除と削除時回転は後で実装します。

参考サイト:
[http://www.geocities.jp/m_hiroi/light/abcruby13.html]
こちらはただの2分探索ですが、ひな形として使わせていただきました。

=end

class Red_Black_Tree

  class Node
    def initialize(key, data, color)
      @key = key
      @data = data
      @color = color
      @left = nil
      @right = nil
    end
    attr_accessor :key, :data, :color, :left, :right
  end

  def initialize
    @root = nil
  end

  # ここからのメソッドはprivate
  private

  def isRed(node)
    if node != nil && (node.color == 0)
      return 1
    else
      return 0
    end
  end

  def isBlack(node)
    if node != nil && (node.color = 1)
      return 1
    else
      return 0
    end
  end

  #部分木の回転。左回転
  def LeftRotation(node)
    rl_node = node.right.left
    r_node = node.right
    r_node.left = node
    r_node.left.right = rl_node
    return r_node
  end

  #部分木の回転。右回転
  def RightRotation(node)
    lr_node = node.left.right
    l_node = node.left
    l_node.right = node
    l_node.right.left = lr_node
    return l_node
  end

  #部分木の２重回転。左回転→右回転
  def LRRotation(node)
    node.left = LeftRotation(node.left)
    return RightRotation(node)
  end

  #部分木の２重回転。右回転→左回転
  def RLRotation(node)
    node.right = RightRotation(node.right)
    return LeftRotation(node)
  end

  #挿入時の赤黒木修正
  def KeepTreesBalance(node)
    if node.color != 1
      return node
    elsif isRed(node.left) == 1 && isRed(node.left.left) == 1
      node = RightRotation(node)
      node.left.color = 1
    elsif isRed(node.left) == 1 && isRed(node.left.right) == 1
      node = LRRotation(node)
      node.left.color = 1
    elsif isRed(node.right) == 1 && isRed(node.right.left) == 1
      node = RLRotation(node)
      node.right.color = 1
    elsif isRed(node.right) == 1 && isRed(node.right.right) == 1
      node = LeftRotation(node)
      node.right.color = 1
    end
    return node
  end

  # 探索
  def search(node, key)
    while node
      if key == node.key
        return node
      elsif key < node.key
        node = node.left
      else
        node = node.right
      end
    end
    return nil
  end

  # 挿入
  def insert_node(node, key, data)
    if node == nil
      return Node.new(key, data, 0)
    elsif key == node.key
      node.data = data
      return node
    elsif key < node.key
      node.left = insert_node(node.left, key, data)
      new_tree = KeepTreesBalance(node)
      return new_tree
    elsif key > node.key
      node.right = insert_node(node.right, key, data)
      new_tree = KeepTreesBalance(node)
      return new_tree
    end
  end

  # ここからのメソッドはpublic
  public

  # ユーザが使う探索メソッド
  def [](key)
    node = search(@root, key)
    if node
      return node.data
    else
      return nil
    end
  end

  # ユーザが使う挿入メソッド
  def []=(key, data)
    @root = insert_node(@root, key, data)
    @root.color = 1
    return data
  end
end


if __FILE__ == $0

  t = Red_Black_Tree.new
  10.times do |x|
    t[x+1]=(x+1)*100
  end
  10.times do |x|
    t[x+1]=(x+1)*100
  end
  10.times do |x|
    print t[x+1], "\n"
  end
end
